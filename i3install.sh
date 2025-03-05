#!/bin/bash
# Script para configurar i3 automáticamente
# Este script creará el archivo de configuración de i3 en ~/.config/i3/config
# Asegúrate de tener instalado i3 y los paquetes necesarios (i3-gaps, polybar, alacritty, etc.)

# Definir el directorio y archivo de configuración
CONFIG_DIR="$HOME/.config/i3"
CONFIG_FILE="$CONFIG_DIR/config"

# Crear el directorio de configuración si no existe
mkdir -p "$CONFIG_DIR"

# Crear el archivo de configuración de i3 con un heredoc
# Usamos <<'EOF' para que los $ se mantengan literalmente
cat << 'EOF' > "$CONFIG_FILE"
############################################
#       Configuración predeterminada i3
############################################

# Elimina la i3bar predeterminada
exec --no-startup-id killall i3bar

# Define la tecla modificadora: Mod4 (tecla Windows)
set $mod Mod4

# Define la terminal predeterminada (alacritty, por ejemplo)
set $term alacritty

# Fuente para títulos y barra (usando pango)
font pango:monospace 10

############################################
#       Arranque de aplicaciones
############################################

# Ejecuta Polybar con la configuración 'mybar'
exec --no-startup-id polybar mybar

############################################
#       Atajos de teclado básicos
############################################

# Abrir la terminal
bindsym $mod+Return exec $term

# Abrir dmenu (centrado)
bindsym $mod+d exec dmenu_run -c

# Cerrar ventana
bindsym $mod+Shift+q kill

# Cambiar foco entre ventanas
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Cambiar de workspace
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2

# Recargar la configuración de i3
bindsym $mod+Shift+c reload

# Salir de i3 (logout)
bindsym $mod+Shift+e exit

############################################
#       Configuración de gaps (i3-gaps)
############################################

gaps inner 2
gaps outer 2

############################################
#       Otros comandos y ajustes
############################################

# Abrir menu apagado/reiniciar/cerrar sesion
bindsym $mod+Shift+p exec ~/.config/i3/menu_shutdown.sh

# Realizar copia de seguridad
bindsym $mod+Shift+b exec ~/.config/i3/backup_config.sh
EOF

echo "El archivo de configuración de i3 se ha creado en: $CONFIG_FILE"

echo "Reiniciando i3 para aplicar la configuración..."
i3-msg restart
