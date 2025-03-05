#!/bin/bash
cd /tmp

sudo rm -rf dmenu-flexipatch

git clone https://github.com/bakkeby/dmenu-flexipatch.git

cd dmenu-flexipatch

# 2. Activar módulos útiles modificando el archivo de configuración de parches.
# Se asume que en "patches.def.h" cada parche se activa cambiando su valor de 0 a 1.
# Ejemplo: para activar el parche center, se espera que exista una línea:
#   #define CENTER_PATCH 0
# que se cambiará a:
#   #define CENTER_PATCH 1

# Activa el parche "center"
sed -i 's/#define CENTER_PATCH 0/#define CENTER_PATCH 1/' patches.def.h

# Activa el parche "alpha" (transparencia)
sed -i 's/#define ALPHA_PATCH 0/#define ALPHA_PATCH 1/' patches.def.h

# Activa el parche "border" (borde alrededor de la ventana)
sed -i 's/#define BORDER_PATCH 0/#define BORDER_PATCH 1/' patches.def.h

# Activa el parche "case-insensitive" (búsqueda sin distinguir mayúsculas/minúsculas)
sed -i 's/#define CASE_INSENSITIVE_PATCH 0/#define CASE_INSENSITIVE_PATCH 1/' patches.def.h

# Activa el parche "dynamic_options" (actualiza opciones dinámicamente)
sed -i 's/#define DYNAMIC_OPTIONS_PATCH 0/#define DYNAMIC_OPTIONS_PATCH 1/' patches.def.h

# Puedes agregar más sed para otros parches que te parezcan útiles.

# 3. Compilar e instalar (usa sudo si es necesario para la instalación)
make clean install

echo "dmenu-flexipatch se ha instalado correctamente con los módulos activados."