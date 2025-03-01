#!/bin/bash
# Script de instalación automática de Arch Linux en VirtualBox con i3 y Polybar

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta este script como root."
  exit 1
fi

# Variables de configuración (modifica según convenga)
DISK="/dev/sda"
HOSTNAME="arch-josemanuel"
TIMEZONE="Europe/Madrid"
ROOT_PASSWORD="root"            # Cambiar por una contraseña segura
USER="josemanuel"               # Nombre del usuario
USER_PASSWORD="josemanuel"      # Cambiar por una contraseña segura
USE_BTRFS="no"                  # Cambia a "yes" para usar btrfs en la partición raíz
SWAP_SIZE="2GiB"                # Tamaño de la partición swap (2GiB, por ejemplo)

# 1. Particionado del disco
# Se crea una tabla de particiones msdos (BIOS) con tres particiones:
#   - Una partición de arranque de 512 MB
#   - Una partición de swap (por ejemplo, 2 GiB)
#   - Una partición raíz con el resto del disco

echo "Creando particiones en $DISK..."
parted --script "$DISK" mklabel msdos
parted --script "$DISK" mkpart primary ext4 1MiB 513MiB
parted --script "$DISK" mkpart primary linux-swap 513MiB 2561MiB
parted --script "$DISK" mkpart primary ext4 2561MiB 100%

BOOT_PART="${DISK}1"
SWAP_PART="${DISK}2"
ROOT_PART="${DISK}3"

# 2. Formateo de las particiones
echo "Formateando la partición de arranque $BOOT_PART como ext4..."
mkfs.ext4 "$BOOT_PART"

echo "Formateando la partición swap $SWAP_PART..."
mkswap "$SWAP_PART"
swapon "$SWAP_PART"

if [ "$USE_BTRFS" == "yes" ]; then
  echo "Formateando la partición raíz $ROOT_PART como btrfs..."
  mkfs.btrfs "$ROOT_PART"
else
  echo "Formateando la partición raíz $ROOT_PART como ext4..."
  mkfs.ext4 "$ROOT_PART"
fi

# 3. Montaje de las particiones
echo "Montando la partición raíz en /mnt..."
mount "$ROOT_PART" /mnt
echo "Creando y montando /mnt/boot..."
mkdir /mnt/boot
mount "$BOOT_PART" /mnt/boot

# 4. Instalación del sistema base
echo "Instalando el sistema base..."
pacstrap /mnt base base-devel linux linux-firmware vim git

# 5. Generar fstab
echo "Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Agregar swap a fstab
SWAP_UUID=$(blkid -s UUID -o value "$SWAP_PART")
echo "UUID=${SWAP_UUID} none swap sw 0 0" >> /mnt/etc/fstab

# 6. Configuración básica en chroot
echo "Realizando configuración básica..."
arch-chroot /mnt /bin/bash <<EOF
# Configurar zona horaria y reloj
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Configurar localización y teclado en español
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
loadkeys es

# Configurar hostname
echo "$HOSTNAME" > /etc/hostname

# Establecer contraseña de root
echo "root:$ROOT_PASSWORD" | chpasswd

# Crear usuario y agregarlo al grupo wheel para sudo
useradd -m -G wheel $USER
echo "$USER:$USER_PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Instalar y habilitar NetworkManager
pacman -Sy --noconfirm networkmanager
systemctl enable NetworkManager

# Instalar VirtualBox Guest Additions para mejorar la integración en la VM
pacman -Sy --noconfirm virtualbox-guest-utils
systemctl enable vboxservice

EOF

# 7. Instalación de i3, Polybar y utilidades adicionales
echo "Instalando i3, Polybar y utilidades..."
arch-chroot /mnt /bin/bash <<'EOF'
pacman -Sy --noconfirm i3-gaps i3-wm i3status polybar dmenu rofi

# Configurar .xinitrc para que inicie i3 automáticamente al usar startx
su - $USER -c 'echo "exec i3" > ~/.xinitrc'
EOF

echo "Instalación completa. Ahora viene la configuración de i3 y Polybar."
echo "Cuando estés listo, desmonta la iso y reinicia el sistema."
