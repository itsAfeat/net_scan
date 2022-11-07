#!/bin/bash

# Help menu information
_prg_name="NET STINK"
_cmd_name="net_stink"
_version="0.1"
_link="https://github.com/itsAfeat/net_stink"

# Which scans to do
do_port=0
do_fast=0
do_save=0
file_name=""

##Functions
# Help menu function
function help_menu() {
    echo -e "\n${Bold}${_prg_name}${Color_Off} $_version ( $_link )"
    echo -e "Usage: ${_cmd_name} ${Italic}[parameters] -i [ip_range]${Color_Off}"
    echo -e "\n${HWhite}${Underline}PARAMTERS${Color_Off}"
    echo -e "${Italic}${Bold}\t-h${Color_Off}\t\tThe help menu, what you're looking at dummy."
    echo -e "${Italic}${Bold}\t-i [x.x.x.x]${Color_Off}\tIp range. The range in which the program shold scan in.\n\t\t\t(ex: 192.168.0.* or 192.168.0.0/16)"
    echo -e "${Italic}${Bold}\t-p [x-y]${Color_Off}\tPort range. Same as ip range... but with ports.\n\t\t\t(ex: 443-8080)"
    echo -e "${Italic}${Bold}\t-f${Color_Off}\t\tDo a fast scan. This will make the scan faster, but\n\t\t\tit will also be less accurate."
    echo -e "${Italic}${Bold}\t-o [file]${Color_Off}\tLog that sweet scan to a file."
}


# Check if the user has sed, awk and netcat installed

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


# Get all the flags and set their corresponding values
while getopts i:p:o:fh flag
do
    case "${flag}" in
        i) ip_range=${OPTARG};;
        p) port_range=${OPTARG}; do_port=1;;
        o) file_name=${OPTARG}; do_save=1;;
        f) do_fast=1;;
        h) help_menu; exit;;
    esac
done

# Check if the ip range has been set, if not... show the help menu
if [ -z ${ip_range+x} ]; then
    help_menu
    exit
fi

open_ips=()
open_ports=()
declare -A ip_dict

echo -e "\n${Bold}${Yellow}[!]${Color_Off} Starting host scan\n"

if [ $do_fast -eq 1 ]; then
    timeout=2
else
    timeout=4
fi

if [ $do_save -eq 0 ]; then
    for i in {0..10}; do
        tmp_ip=$(sed "s/*/$i/g" <<< "$ip_range")
        
        _ping=$(ping -W $timeout -c 1 $tmp_ip)
        result=$(echo "$_ping" | awk '/loss/ {print $6}')
        if [ "$result" != "100%" ]; then
            ip=$(echo "$_ping" | awk '/PING/ {print $2}')
            echo -e "${Bold}${Green}[+]${Color_Off} $ip"
            open_ips+=("$ip")
        fi
    done

    echo -e "\n${Bold}${Yellow}[!]${Color_Off} ${Italic}$_prg_name${Color_Off} found ${#open_ips[@]} open host(s)..."

    if [ $do_port -eq 1 ]; then
        echo -e "${Bold}${Yellow}[!]${Color_Off} Starting port scan\n"
        for ip in "${open_ips[@]}"; do
            open_ports=$(nc -z -vv -n $ip $port_range 2>&1 | awk '/open/ {print $3" "($4)}')
            #echo -e "Funny${open_ports[0]}pis"

            if [ -z "${open_ports[0]}" ]; then
                ip_dict["$ip"]="-1"
            else
                ip_dict["$ip"]=$open_ports  
            fi
        done

        echo -e "${Bold}${Green}[+]${Color_Off}Scan finished... Showing results below"
        echo -e "\n--------------------------------------------------------------"

        for key in "${!ip_dict[@]}"; do
            echo -e "${Bold}${Purple}[>]${Color_Off} $key"
            if [ "${ip_dict[$key]}" = "-1" ]; then
                echo -e "\t${Italic}${Bold}No open ports${Color_Off}\n"
            else
                echo -e "\t${Italic}${Bold}${ip_dict[$key]}${Color_Off}\n"
            fi
        done
        
        exit
    fi
else
    echo -e "fat funny ${Bold}fart${Color_Off} moments ;)"
    exit
fi
