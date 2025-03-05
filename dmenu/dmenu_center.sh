#!/bin/bash
# dmenu_center.sh - Lanza dmenu centrado en la pantalla.
# Este script requiere una versión de dmenu parcheada con soporte para opciones de geometría.
# Si no dispones de esa versión, dmenu se lanzará sin posicionamiento personalizado.

# Verificar que xdpyinfo está instalado
if ! command -v xdpyinfo >/dev/null 2>&1; then
    echo "xdpyinfo no está instalado. Instálalo e inténtalo de nuevo."
    exit 1
fi

# Obtener dimensiones de la pantalla (por ejemplo, "1920x1080")
SCREEN_DIMS=$(xdpyinfo | awk '/dimensions/{print $2}')
SCREEN_WIDTH=$(echo "$SCREEN_DIMS" | cut -d'x' -f1)
SCREEN_HEIGHT=$(echo "$SCREEN_DIMS" | cut -d'x' -f2)

# Definir ancho y altura de dmenu.
# En este ejemplo, el ancho será el 50% de la pantalla y la altura 25 píxeles.
DMENU_WIDTH=$(( SCREEN_WIDTH / 2 ))
DMENU_HEIGHT=25

# Calcular las coordenadas para centrar dmenu en la pantalla
DMENU_X=$(( (SCREEN_WIDTH - DMENU_WIDTH) / 2 ))
DMENU_Y=$(( (SCREEN_HEIGHT - DMENU_HEIGHT) / 2 ))

# Lanzar dmenu_run con las opciones de geometría
dmenu_run -x "$DMENU_X" -y "$DMENU_Y" -w "$DMENU_WIDTH" -h "$DMENU_HEIGHT"