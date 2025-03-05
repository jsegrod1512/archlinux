#!/bin/bash

# Asegurar permisos de ejecución
chmod +x ./*

SCRIPTS=("dmenu_config.sh" "i3install.sh" "polybarinstall.sh")

# Ejecutar los scripts en el orden especificado
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        echo "Ejecutando: $script"
        bash "$script"
    else
        echo "Advertencia: No se encontró $script"
    fi
done

# Mover los scripts a su ubicación final en ~/.config/scripts
mkdir -p ~/.config/scripts
cp ./* ~/.config/scripts/
chmod +x ~/.config/scripts/*

# Configurar el backup en cron
BACKUP_SCRIPT="$HOME/.config/scripts/backup_config.sh"
CRON_JOB="0 3 * * 1 $BACKUP_SCRIPT > /dev/null 2>&1"

# Verificar si ya existe el cronjob y agregarlo si no está
(crontab -l | grep -Fq "$BACKUP_SCRIPT") || (crontab -l; echo "$CRON_JOB") | crontab -

echo "Scripts ejecutados!"
echo "--------------------"
echo "Backup semanal configurado en cron (cada lunes a las 03:00 AM)"
