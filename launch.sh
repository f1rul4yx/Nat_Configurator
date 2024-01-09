#!/bin/bash

# Author: Diego Vargas (f1rul4yx)

# Colors
negrita="\033[1m"
subrayado="\033[4m"
negro="\033[30m"
rojo="\033[31m"
verde="\033[32m"
amarillo="\033[33m"
azul="\033[34m"
magenta="\033[35m"
cian="\033[36m"
blanco="\033[37m"
reset="\033[0m"

# Functions
function root_verification() {
    clear
    if [ "$EUID" -ne 0 ]; then
        echo -e "\n${negrita}${rojo}Este script debe ser ejecutado como usuario root${reset}"
        exit 1
    fi
}
function username() {
    clear
    echo -e "\n${negrita}Escribe tu nombre de usuario perfectamente:${reset} \c"
    read username
}
function sudoers() {
    clear
    if ! grep "${username}" /etc/sudoers; then
        echo -e "${username}    ALL=(ALL:ALL) ALL" >> /etc/sudoers
    fi &>/dev/null
}
function question() {
    echo -e "\n${negrita}Escribe el nombre de la interfaz de red que se comunica con el exterior:${reset} \c"
    read networkInterface
}
function commands() {
    sudo apt-get update -y
    sudo apt-get install iptables iptables-persistent -y
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
    sudo sysctl -p
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F
    sudo iptables -t nat -X
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -t nat -A POSTROUTING -o ${networkInterface} -j MASQUERADE
    sudo iptables-save > /etc/iptables/rules.v4
}
function close() {
    echo -e "\n${negrita}${verde}Programa lanzado con exito${reset}"
    exit
}

# Program
root_verification
username
sudoers
question
commands
close
