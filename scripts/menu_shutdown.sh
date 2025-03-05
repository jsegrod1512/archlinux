#!/bin/bash

# Opciones del menú
opciones="Apagar\nReiniciar\nCerrar sesión"

# Mostrar el menú y capturar la selección
seleccion=$(echo -e $opciones | dmenu -fn 'pango-20' -l 10 -bw 3 -i -p "Selecciona una acción:")

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