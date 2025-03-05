#!/bin/bash

# Directorio donde están los scripts
SCRIPTS_DIR="$(dirname "$(realpath "$0")")/scripts"

# Asegurar permisos de ejecución
chmod +x "$SCRIPTS_DIR"/*.sh

# Excluir `archinstall.sh` y los scripts de instalación de la ejecución
EXCLUDED_SCRIPTS=("archinstall.sh" "config.sh")

# Scripts de instalación que deben ejecutarse en orden
INSTALL_SCRIPTS=("dmenu_config.sh" "i3install.sh" "polybarinstall.sh")

# Ejecutar los scripts en el orden especificado
for script in "${INSTALL_SCRIPTS[@]}"; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        echo "Ejecutando: $script"
        bash "$SCRIPTS_DIR/$script"
    else
        echo "Advertencia: No se encontró $script"
    fi
done

# Mover los scripts a su ubicación final en ~/.config/scripts
mkdir -p ~/.config/scripts
mv "$SCRIPTS_DIR"/* ~/.config/scripts/

# Configurar el backup en cron
BACKUP_SCRIPT="$HOME/.config/scripts/backup_config.sh"
CRON_JOB="0 3 * * 1 $BACKUP_SCRIPT > /dev/null 2>&1"

# Verificar si ya existe el cronjob y agregarlo si no está
(crontab -l | grep -Fq "$BACKUP_SCRIPT") || (crontab -l; echo "$CRON_JOB") | crontab -

echo "Todos los scripts han sido ejecutados y movidos a ~/.config/scripts"
echo "Backup semanal configurado en cron (cada lunes a las 03:00 AM)"
