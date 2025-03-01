#!/bin/bash
# Script para configurar Polybar automáticamente.
# Crea el directorio de configuración de Polybar y escribe un archivo de configuración de ejemplo.

# Directorio donde se almacenará la configuración de Polybar
CONFIG_DIR="$HOME/.config/polybar"
# Archivo de configuración principal de Polybar
CONFIG_FILE="$CONFIG_DIR/config"

echo "Creando directorio de configuración en: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

echo "Creando archivo de configuración en: $CONFIG_FILE"
# Usamos un heredoc para escribir la configuración de ejemplo.
# El delimitador se define entre comillas simples para que no se expandan variables.
cat << 'EOF' > "$CONFIG_FILE"
################################################################################
# Configuración predeterminada para Polybar
# Este archivo es un ejemplo para configurar Polybar. Puedes editarlo según tus
# necesidades.
################################################################################

[bar/mybar]
; Dimensiones y posición de la barra
width = 100%
height = 30
offset-x = 0
offset-y = 0

; Colores: fondo y primer plano
background = #222222
foreground = #aaaaaa

; Módulos a mostrar en el centro (puedes agregar más módulos separados por espacios)
modules-center = date

; Fuentes (puedes cambiar a otra fuente instalada en tu sistema)
font-0 = "SauceCodePro Nerd Font:size=10;1"
font-1 = "Noto Sans:size=10;1"

################################################################################
; Módulo de fecha y hora
[module/date]
type = internal/date
interval = 1
format = %Y-%m-%d %H:%M:%S
; Subrayado en el formato (opcional)
format-underline = #ff0000

################################################################################
; Aquí puedes agregar más módulos o personalizar la configuración según tus necesidades.
; Consulta la documentación oficial de Polybar en: https://polybar.github.io/docs/
EOF

echo "La configuración de Polybar se ha creado correctamente en: $CONFIG_FILE"
