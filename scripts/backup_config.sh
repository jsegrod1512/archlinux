#!/bin/bash

# Directorio de origen
directorio_origen="$HOME/.config"

# Directorio de destino para las copias de seguridad
directorio_destino="$HOME/copias_seguridad"

# Nombre del archivo de respaldo con fecha y hora
archivo_respaldo="scripts_backup_$(date +'%Y%m%d_%H%M%S').tar.gz"

# Crear el directorio de destino si no existe
mkdir -p "$directorio_destino"

# Función para realizar la copia de seguridad
realizar_backup() {
    tar -czf "$directorio_destino/$archivo_respaldo" -C "$directorio_origen" .
    notify-send "Copia de seguridad completada" "La carpeta .config ha sido respaldada en $directorio_destino/$archivo_respaldo"
}

# Si estamos en una sesión gráfica y se detecta i3, mostramos el menú con dmenu;
# de lo contrario, se ejecuta el respaldo sin confirmación (por ejemplo, en cron).
if [ -n "$DISPLAY" ] && pgrep -x i3 > /dev/null; then
    respuesta=$(echo -e "Sí\nNo" | dmenu -fn 'pango-20' -bw 3 -p "¿Deseas realizar una copia de seguridad?")
    if [ "$respuesta" == "Sí" ]; then
        realizar_backup
    else
        notify-send "Copia de seguridad cancelada" "No se ha realizado ninguna copia de seguridad."
    fi
else
    realizar_backup
fi