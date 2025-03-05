#!/bin/bash
# Script para configurar y reiniciar Polybar
# Se asume que Polybar está instalado en el sistema

# Definir el directorio y archivo de configuración de Polybar
CONFIG_DIR="$HOME/.config/polybar"
CONFIG_FILE="$CONFIG_DIR/config.ini"  # Usamos extensión .ini según convención

# Crear el directorio de configuración si no existe
echo "Creando directorio de configuración en: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# Copiar archivo de configuración de ejemplo, si aún no existe, desde una ruta típica.
# Nota: La ubicación del archivo de ejemplo puede variar; en Arch suele estar en /usr/share/doc/polybar/example/
if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "/usr/share/doc/polybar/example/config.ini" ]; then
        echo "Copiando archivo de configuración de ejemplo a: $CONFIG_FILE"
        cp "/usr/share/doc/polybar/example/config.ini" "$CONFIG_FILE"
    else
        echo "No se encontró el archivo de ejemplo en /usr/share/doc/polybar/example/config.ini."
        echo "Por favor, revisa la ubicación del archivo de ejemplo de Polybar."
    fi
else
    echo "El archivo de configuración ya existe: $CONFIG_FILE"
fi

# Reiniciar Polybar: si ya está corriendo, lo matamos y lo reiniciamos
if pgrep -x "polybar" > /dev/null; then
    echo "Polybar se está ejecutando. Reiniciando..."
    killall polybar
    # Esperar unos segundos para asegurarnos de que se cierre
    sleep 2
fi

# Iniciar Polybar con la configuración "mybar" (debes tener definido ese perfil en el archivo de configuración)
echo "Iniciando Polybar..."
polybar mybar &

echo "Polybar ha sido iniciado con la configuración ubicada en: $CONFIG_FILE"
