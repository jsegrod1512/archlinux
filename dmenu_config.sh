#!/bin/bash

cd /tmp

# Clona el repositorio de dmenu
git clone https://git.suckless.org/dmenu

# Entra en el directorio de dmenu
cd dmenu

# Descarga el parche de centrado
wget https://tools.suckless.org/dmenu/patches/center/dmenu-center-20240616-36c3d68.diff

# Aplica el parche
patch < dmenu-center-20240616-36c3d68.diff

# Compila dmenu
make

# Instala dmenu (puede requerir permisos de superusuario)
sudo make install

