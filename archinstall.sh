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

    # Se crea el archivo de configuración para que Xorg use el teclado español
    cat << 'XEOF' > /etc/X11/xorg.conf.d/00-keyboard.conf
      Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "es"
        Option "XkbModel" "pc105"
      EndSection
    XEOF

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
    pacman -Sy --noconfirm i3-gaps i3-wm i3status polybar dmenu alacritty wget

    # 6.11. Aplicaciones adicionales
    pacman -Sy firefox rofi 
EOF

echo "===== [7/7] FINALIZANDO INSTALACION ====="
echo "Desmontando particiones y desactivando swap..."
umount -R /mnt
swapoff "$SWAP_PART"

echo "Instalación finalizada. Reiniciando el sistema en 30 segundos... Recuerda desmontar el disco"
sleep 30
reboot
