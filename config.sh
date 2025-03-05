#!/bin/bash

# Asegurar permisos de ejecución
chmod +x ./scripts/*.sh

chmod +x ./*.sh

SCRIPTS=("dmenu_config.sh" "i3install.sh" "polybarinstall.sh")

# Ejecutar los scripts en el orden especificado
for script in "${SCRIPTS[@]}"; do
    if [[ -f "./$script" ]]; then
        echo "Ejecutando: $script"
        bash "./$script"
    else
        echo "Advertencia: No se encontró $script"
    fi
done

# Mover los scripts a su ubicación final en ~/.config/scripts
mkdir -p ~/.config/scripts
cp ./* ~/.config/scripts/
chmod +x ~/.config/scripts/*.sh

# write out current crontab
crontab -l > mycron
# echo new cron into cron file
echo "0 3 * * 1 $HOME/.config/scripts/backup_config.sh" >> mycron
# install new cron file
crontab mycron
rm mycron

echo "Scripts ejecutados!"
echo "--------------------"
echo "Backup semanal configurado en cron (cada lunes a las 03:00 AM)"
