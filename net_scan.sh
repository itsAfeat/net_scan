#!/bin/bash

# Help menu information
version="0.1"
link="https://github.com/itsafeat"

# Which scans to do
do_os=0
do_port=0
do_fast=0

# Help menu function
function help_menu() {
    echo -e "${Bold}net_scan${Color_Off} $version ( $link )"
    echo -e "Usage: net_scan ${Italic}[parameters] -i [ip_range]${Color_Off}"
    echo -e "\n${HWhite}${Underline}PARAMTERS:${Color_Off}"
    echo -e "${Italic}${Bold}\t-h${Color_Off}:\tThe help menu, what you're looking at dummy."
    echo -e "${Italic}${Bold}\t-i${Color_Off}:\tIp range. The range in which the program shold scan in.\n\t\t(ex: 192.168.0.* or 192.168.0.0/16)"
    echo -e "${Italic}${Bold}\t-p${Color_Off}:\tPort range. Same as ip range... but with ports.\n\t\t(ex: 443-8080)"
    echo -e "${Italic}${Bold}\t-o${Color_Off}:\tEnable the OS scan function (doesn't work yet)."
    echo -e "${Italic}${Bold}\t-f${Color_Off}:\tDo a fast scan."
}


# Include the colors script
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/colors.sh"

# Check if the '-h' flag is in the argument array
if printf '%s\0' "$@" | grep -Fxqz -- '-h'; then
    help_menu
    exit
fi

# Check if the '-o' flag is in the argument array
#if printf '%s\0' "$@" | grep -Fxqz -- '-o'; then
#    do_port=1
#fi

# Get all the flags and set their corresponding
while getopts i:p:o:f: flag
do
    case "${flag}" in
        i) ip_range=${OPTARG};;
        p) port_range=${OPTARG}; do_port=1;;
        o) do_os=1;;
        f) do_fast=1;;
    esac
done

# Check if the ip range has been set, if not... show the help menu
if [ -z ${ip_range+x} ]; then
    help_menu
    exit
fi


if [ $do_fast -eq 1 ]; then
    echo -e "\tnmap -T4 -F $ip_range"
elif [ $do_os -eq 1 ]; then
    echo -e "\tnmap -sV -T4 -O -F --version-light $ip_range"
else
    echo -e "\tnmap -T4 -A -v $ip_range"
fi


exit
