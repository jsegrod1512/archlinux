#!/bin/bash
# Script de instalación automática de Arch Linux con GRUB, LightDM e i3 + Polybar

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta este script como root (ej.: sudo su)."
  exit 1
fi

# Variables de configuración
DISK="/dev/sda"                 # Disco a formatear (modo BIOS/MBR)
HOSTNAME="arch-maquina"         # Nombre del host
TIMEZONE="Europe/Madrid"        # Zona horaria
ROOT_PASSWORD="root"            # Contraseña de root
USER="usuario"                  # Nombre de usuario
USER_PASSWORD="usuario"         # Contraseña de ese usuario
USE_BTRFS="no"                  # "yes" para formatear la raíz con btrfs
SWAP_SIZE="2GiB"                # Tamaño de la partición swap

echo "===== [1/7] CREANDO PARTICIONES ====="
parted --script "$DISK" mklabel msdos
# Partición de arranque: 512 MB (ext4)
parted --script "$DISK" mkpart primary ext4 1MiB 513MiB
# Partición swap: 2GiB (ajustable con la variable SWAP_SIZE)
parted --script "$DISK" mkpart primary linux-swap 513MiB 2561MiB
# Partición raíz: el resto del disco
parted --script "$DISK" mkpart primary ext4 2561MiB 100%

BOOT_PART="${DISK}1"
SWAP_PART="${DISK}2"
ROOT_PART="${DISK}3"

echo "===== [2/7] FORMATEANDO PARTICIONES ====="
# 2.1. /boot en ext4
mkfs.ext4 "$BOOT_PART"

# 2.2. swap
mkswap "$SWAP_PART"
swapon "$SWAP_PART"

# 2.3. raíz en ext4 (o btrfs si USE_BTRFS='yes')
if [ "$USE_BTRFS" == "yes" ]; then
  mkfs.btrfs "$ROOT_PART"
else
  mkfs.ext4 "$ROOT_PART"
fi

echo "===== [3/7] MONTANDO PARTICIONES ====="
mount "$ROOT_PART" /mnt
mkdir /mnt/boot
mount "$BOOT_PART" /mnt/boot

echo "===== [4/7] INSTALANDO SISTEMA BASE ====="
pacstrap /mnt base base-devel linux linux-firmware vim git \
  xorg-server xorg-xinit  # Servidor X para entorno gráfico

echo "===== [5/7] GENERANDO FSTAB ====="
genfstab -U /mnt >> /mnt/etc/fstab

# Agregar swap al fstab
SWAP_UUID=$(blkid -s UUID -o value "$SWAP_PART")
echo "UUID=$SWAP_UUID none swap sw 0 0" >> /mnt/etc/fstab

echo "===== [6/7] CONFIGURACION EN CHROOT ====="
arch-chroot /mnt /bin/bash <<EOF
    # 6.1. Configurar zona horaria y reloj
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc

    # 6.2. Configurar localización y teclado en español
    echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=es_ES.UTF-8" > /etc/locale.conf
    loadkeys es
    # Configura el teclado también en la interfaz
    setxkbmap es

    # 6.3. Configurar hostname
    echo "$HOSTNAME" > /etc/hostname

    # 6.4. Establecer contraseña de root
    echo "root:$ROOT_PASSWORD" | chpasswd

    # 6.5. Crear usuario y agregarlo al grupo wheel para sudo
    useradd -m -G wheel $USER
    echo "$USER:$USER_PASSWORD" | chpasswd
    sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

    # 6.6. Instalar y habilitar NetworkManager
    pacman -Sy --noconfirm networkmanager
    systemctl enable NetworkManager

    # 6.7. Instalar y habilitar VirtualBox Guest Additions (opcional)
    pacman -Sy --noconfirm virtualbox-guest-utils
    systemctl enable vboxservice

    # 6.8. Instalar GRUB (modo BIOS/MBR) y generar configuración
    pacman -Sy --noconfirm grub os-prober
    grub-install --target=i386-pc $DISK
    grub-mkconfig -o /boot/grub/grub.cfg

    # 6.9. Instalar LightDM (display manager) y habilitarlo
    pacman -Sy --noconfirm lightdm lightdm-gtk-greeter
    systemctl enable lightdm

    # 6.10. Instalar i3, Polybar y utilidades
    pacman -Sy --noconfirm i3-gaps i3-wm i3status polybar dmenu rofi alacritty

    # 6.11. Crear configuración personalizada de i3 para evitar el prompt inicial
    su - $USER -c 'mkdir -p ~/.config/i3'
    su - usuario -c "cat <<'EOT' > ~/.config/i3/config
    ############################################
    #       Configuración predeterminada i3
    ############################################

    # Define la tecla modificadora: Mod4 (tecla Windows)
    set \$mod Mod4

    # Define la terminal predeterminada (alacritty, por ejemplo)
    set \$term alacritty

    # Fuente para títulos y barra (usando pango)
    font pango:monospace 10

    ############################################
    #       Arranque de aplicaciones
    ############################################

    # Ejecuta Polybar con la configuración "mybar" (asegúrate de tener un archivo de configuración en ~/.config/polybar/config)
    exec --no-startup-id polybar mybar

    ############################################
    #       Atajos de teclado básicos
    ############################################

    # Abrir la terminal
    bindsym \$mod+Return exec \$term

    # Cerrar ventana
    bindsym \$mod+Shift+q kill

    # Cambiar foco entre ventanas
    bindsym \$mod+j focus left
    bindsym \$mod+k focus down
    bindsym \$mod+l focus up
    bindsym \$mod+semicolon focus right

    # Cambiar de workspace
    bindsym \$mod+1 workspace 1
    bindsym \$mod+2 workspace 2

    # Recargar la configuración de i3
    bindsym \$mod+Shift+c reload

    # Salir de i3 (logout)
    bindsym \$mod+Shift+e exit

    ############################################
    #       Configuración de gaps (i3-gaps)
    ############################################

    gaps inner 10
    gaps outer 10

    ############################################
    #       Otros comandos y ajustes
    ############################################

    # Puedes añadir aquí más bindings o comandos para iniciar otras aplicaciones,
    # por ejemplo, lanzar rofi:
    # bindsym \$mod+d exec rofi -show run

    # Establecer wallpaper con feh (opcional)
    # exec --no-startup-id feh --bg-scale /ruta/a/tu/wallpaper.jpg
    EOT"
EOF

echo "===== [7/7] FINALIZANDO INSTALACION ====="
echo "Desmontando particiones y desactivando swap..."
umount -R /mnt
swapoff "$SWAP_PART"

echo "Instalación finalizada. Reiniciando el sistema en 30 segundos... Recuerda desmontar el disco"
sleep 30
reboot
