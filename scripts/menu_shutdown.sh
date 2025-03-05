#!/bin/bash

# Establece un PATH completo
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Opciones del menú
opciones="Apagar\nReiniciar\nCerrar sesión"

# Mostrar el menú y capturar la selección
seleccion=$(echo -e $opciones | dmenu -i -p "Selecciona una acción:")

# Ejecutar la acción correspondiente
case "$seleccion" in
    Apagar)
        systemctl poweroff
        ;;
    Reiniciar)
        systemctl reboot
        ;;
    "Cerrar sesión")
        i3-msg exit
        ;;
esac