#!/bin/bash

# Help menu information
_prg_name="NET STINK"
_cmd_name="net_stink"
_version="0.1"
_link="https://github.com/itsAfeat/net_stink"

# Which scans to do
do_os=0
do_port=0
do_fast=0

##Functions
# Help menu function
function help_menu() {
    echo -e "\n${Bold}${_prg_name}${Color_Off} $_version ( $_link )"
    echo -e "Usage: ${_cmd_name} ${Italic}[parameters] -i [ip_range]${Color_Off}"
    echo -e "\n${HWhite}${Underline}PARAMTERS${Color_Off}"
    echo -e "${Italic}${Bold}\t-h${Color_Off}\tThe help menu, what you're looking at dummy."
    echo -e "${Italic}${Bold}\t-i${Color_Off}\tIp range. The range in which the program shold scan in.\n\t\t(ex: 192.168.0.* or 192.168.0.0/16)"
    echo -e "${Italic}${Bold}\t-p${Color_Off}\tPort range. Same as ip range... but with ports.\n\t\t(ex: 443-8080)"
    echo -e "${Italic}${Bold}\t-o${Color_Off}\tTell ${Italic}${_prg_name}${Color_Off} to try and detect scanned targets OS ${Italic}(requires root)${Color_Off}."
    echo -e "${Italic}${Bold}\t-f${Color_Off}\tDo a fast scan. If this is not enabled, ${Italic}${_prg_name}${Color_Off} will\n\t\tdo a regular aggresive/intense scan."
}


# Check if the user is root
if [ "$EUID" -ne 0 ]; then
    is_root=0
else
    is_root=1
fi


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
while getopts i:p:of flag
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


echo -e "\n${Bold}${Yellow}[!]${Color_Off} Starting scan of range $ip_range\n"


# Change all this to a more modular solution. So if $do_os is 1 add -O to the nmap scan
if [ $do_fast -eq 1 ]; then
    nmap -T4 -F -oG - $ip_range | grep "Status: Up"
elif [ $do_os -eq 1 ]; then
    if [ $is_root -eq 0 ]; then
        echo -e "${Bold}${Red}[x]${Color_Off} Error, OS detection needs root, please run again... but as root"
        exit
    fi
    nmap -sV -T4 -O -F -oG - --version-light $ip_range | grep "Status: Up"
else
    nmap -T4 -A -v -oG - $ip_range | grep "Status: Up"
fi

echo -e "\n${Bold}${Green}[+]${Color_Off} Scan completed"

exit
