#!/bin/bash

# Directorio de origen
directorio_origen="$HOME/scripts"

# Directorio de destino para las copias de seguridad
directorio_destino="$HOME/copias_seguridad"

# Nombre del archivo de respaldo con fecha y hora
archivo_respaldo="scripts_backup_$(date +'%Y%m%d_%H%M%S').tar.gz"

# Crear el directorio de destino si no existe
mkdir -p "$directorio_destino"

# Función para realizar la copia de seguridad
realizar_backup() {
    tar -czf "$directorio_destino/$archivo_respaldo" -C "$directorio_origen" .
    notify-send "Copia de seguridad completada" "La carpeta scripts ha sido respaldada en $directorio_destino/$archivo_respaldo"
}

# Verificar si el script se ejecuta desde cron o manualmente
if [ -t 1 ]; then
    # Ejecución manual
    respuesta=$(echo -e "Sí\nNo" | dmenu -p "¿Deseas realizar una copia de seguridad?")
    if [ "$respuesta" == "Sí" ]; then
        realizar_backup
    else
        notify-send "Copia de seguridad cancelada" "No se ha realizado ninguna copia de seguridad."
    fi
else
    # Ejecución desde cron (sin confirmación)
    realizar_backup
fi
