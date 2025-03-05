#!/bin/bash

# Asegurar permisos de ejecución
chmod +x ./*

./dmenu_config.sh
./polybarinstall.sh
./i3install.sh

# Mover los scripts a su ubicación final en ~/.config/scripts
mkdir -p ~/.config/scripts
cp -r scripts/* ~/.config/scripts/
chmod +x ~/.config/scripts/*


grep -q "neofetch" "$HOME/.bashrc" || echo "neofetch" >> "$HOME/.bashrc"
# Recarga el .bashrc para aplicar los cambios en la sesión actual
source "$HOME/.bashrc"

# Configurar el backup en cron
BACKUP_SCRIPT="$HOME/.config/scripts/backup_config.sh"
CRON_JOB="0 3 * * 1 $BACKUP_SCRIPT > /dev/null 2>&1"

# Verificar si ya existe el cronjob y agregarlo si no está
(crontab -l | grep -Fq "$BACKUP_SCRIPT") || (crontab -l; echo "$CRON_JOB") | crontab -

echo "Scripts ejecutados!"
echo "--------------------"
echo "Backup semanal configurado en cron (cada lunes a las 03:00 AM)"
