# Instalación Automatizada de Arch Linux con i3 y Polybar

Este repositorio contiene una serie de scripts para automatizar la instalación de Arch Linux, configurando GRUB, LightDM, i3 (con i3-gaps y Polybar) y otros componentes esenciales. Los scripts se dividen en varias etapas, desde el particionado del disco hasta la configuración final del entorno gráfico.

## Contenido del Repositorio

- **archinstall.sh**  
  Script principal que automatiza la instalación del sistema. Realiza:
  - Creación y formateo de particiones (boot, swap, raíz).
  - Montaje de particiones e instalación del sistema base.
  - Configuración en *chroot*: zona horaria, locales, teclado (loadkeys), hostname, usuarios, gestor de arranque (GRUB) y servicios (NetworkManager, LightDM, VirtualBox Guest Additions, etc.).
  - Desmontaje de particiones y reinicio final.

- **config.sh**  
  Script para la configuración post-instalación que:
  - Ejecuta el script de configuración de **dmenu**.
  - Ejecuta el script de configuración de **Polybar**.
  - Ejecuta el script de configuración de **i3**.
  - Copia scripts adicionales a `~/.config/scripts`.
  - Configura un backup semanal a través de *cron*.

- **dmenu_config.sh**  
  Configura y compila *dmenu* activando parches útiles (por ejemplo, center, transparencia, borde, búsqueda sin mayúsculas, opciones dinámicas).

- **i3install.sh**  
  Crea la configuración predeterminada para *i3*, definiendo atajos de teclado, terminal predeterminada (alacritty), inicio de Polybar y otros comandos (por ejemplo, para reiniciar i3 o abrir un menú de apagado).

- **polybarinstall.sh**  
  Configura *Polybar*, copiando un archivo de configuración de ejemplo (si existe) y adaptándolo para iniciar la barra con el nombre "mybar". Además, se encarga de reiniciar *Polybar* si ya se encuentra en ejecución.

- **scripts/backup_config.sh**  
  Realiza una copia de seguridad de la carpeta `.config` y, en sesiones gráficas con *i3*, muestra un menú de confirmación mediante *dmenu*.

- **scripts/menu_shutdown.sh**  
  Muestra un menú sencillo con *dmenu* para elegir entre apagar, reiniciar o cerrar la sesión.

## Proceso de Instalación

### 1. Preparar el Entorno

1. **Configurar el teclado**:  
   Antes de iniciar la instalación, asegúrate de que el layout del teclado esté configurado en español ejecutando:
   ```bash
   loadkeys es
   ```

2. **Instalar Git**:  
   Si aún no lo tienes, instala Git con:
   ```bash
   sudo pacman -Sy git
   ```

### 2. Clonar el Repositorio

Clona el repositorio en tu sistema:
```bash
git clone https://github.com/tu_usuario/tu_repositorio.git
cd tu_repositorio
```

### 3. Asignar Permisos de Ejecución

Da permisos de ejecución al script principal:
```bash
chmod +x archinstall.sh
```

### 4. Personalizar la Instalación

Puedes editar el archivo `archinstall.sh` para ajustar variables como:
- Disco a formatear (`DISK`)
- Nombre del host (`HOSTNAME`)
- Zona horaria (`TIMEZONE`)
- Contraseñas de *root* y del usuario
- Otras opciones (por ejemplo, usar *btrfs* en lugar de *ext4*)

### 5. Ejecutar el Script de Instalación

Ejecuta el script como superusuario:
```bash
sudo ./archinstall.sh
```

El script realizará los siguientes pasos:
- **Crear particiones**: Boot, swap y raíz.
- **Formatear y montar**: Aplica los sistemas de archivos y activa la partición swap.
- **Instalar el sistema base**: Con *pacstrap* y genera el archivo `fstab`.
- **Configurar en chroot**: Ajusta la zona horaria, locales, teclado, hostname, contraseñas, crea el usuario, configura GRUB y habilita servicios.
- **Finalizar instalación**: Desmonta las particiones, desactiva el swap y reinicia el sistema.

### 6. Configuración Post-Instalación

Una vez que el sistema se reinicie e inicies sesión:

1. Abre la terminal (por ejemplo, con **Windows + Enter** en *i3*).
2. Si no lo tienes ya en tu directorio de usuario, clona nuevamente el repositorio.
3. Asigna permisos de ejecución al script de configuración:
   ```bash
   chmod +x config.sh
   ```
4. Ejecuta el script:
   ```bash
   ./config.sh
   ```

El script **config.sh** se encargará de:
- Configurar *dmenu* mediante **dmenu_config.sh**.
- Configurar y reiniciar *Polybar* mediante **polybarinstall.sh**.
- Crear la configuración predeterminada de *i3* mediante **i3install.sh**.
- Copiar scripts adicionales a `~/.config/scripts`.
- Configurar una tarea *cron* para realizar backups semanales.

### 7. Finalización

Tras la ejecución de los scripts:
- El sistema estará configurado y listo para usarse.
- Podrás iniciar sesión en *i3*, abrir la terminal con **Windows + Enter**, y disfrutar de un entorno de trabajo optimizado y personalizado.