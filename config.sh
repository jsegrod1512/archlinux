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

# Para evitar problemas al ejecutar scripts desde $HOME/.config/scripts
# lo añadimos al PATH
DIR="$HOME/.config/scripts"
# Verifica si el directorio existe
if [ -d "$DIR" ]; then
    # Añade el directorio al PATH si no está ya presente
    if [[ ":$PATH:" != *":$DIR:"* ]]; then
        echo "Añadiendo $DIR al PATH..."
        export PATH="$PATH:$DIR"
        echo 'export PATH="$PATH:'"$DIR"'"' >> "$HOME/.bashrc"
        # Recarga el .bashrc para aplicar los cambios en la sesión actual
        source "$HOME/.bashrc"
        echo "Directorio añadido y PATH actualizado."
    else
        echo "El directorio $DIR ya está en el PATH."
    fi
else
    echo "El directorio $DIR no existe."
fi

# Configurar el backup en cron
BACKUP_SCRIPT="$HOME/.config/scripts/backup_config.sh"
CRON_JOB="0 3 * * 1 $BACKUP_SCRIPT > /dev/null 2>&1"

# Verificar si ya existe el cronjob y agregarlo si no está
(crontab -l | grep -Fq "$BACKUP_SCRIPT") || (crontab -l; echo "$CRON_JOB") | crontab -

echo "Scripts ejecutados!"
echo "--------------------"
echo "Backup semanal configurado en cron (cada lunes a las 03:00 AM)"
