#!/bin/bash

#####################################################################################
# @author Anatoly Gaidai (see avgaidai.github.io)                                   #
#                                                                                   #
# This script 
#                                                                                   #
# Script returns 0 and prints out all useful parameters obtained from the specified #
# config file if the script is successfully executed, or prints out error message   #
# and returns one of the following non-zero error codes:                            #
# 1 -- not enough script arguments;                                                 #
# 2 -- specified file is not exist.                                                 #
#                                                                                   #
#####################################################################################


# Following variables prefixed with  'FONT_' (and END_FORMATTING variable) are
# escape sequences for formatting printout
FONT_BOLD="\033[1m"
FONT_ITALIC="\033[3m"

FONT_YELLOW="\033[33m"
FONT_RED="\033[31m"
FONT_BLUE="\033[34m"
FONT_GREEN="\033[32m"

END_FORMATTING="\033[0m"

CONFIG_FILE="bc_system.cfg"

# Checking for a config file.
# If the config file doesn't exist it will be created,
# but without parameters values, you need to set them yourself.
if [[ ! -f $CONFIG_FILE ]]
then
    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- No such $FONT_INTALIC$FONT_BLUE$CONFIG_FILE$END_FORMATTING!\n" \
         "NOTE: The config file will be automatically created in the" \
         "$FONT_ITALIC$FONT_BLUE$PWD$END_FORMATTING directory. It must be filled" \
         "in according to the instructions specified in the comments to the" \
         "config file." 1>&2

    echo -e " #\n" \
         "# This is config file for blucherry system.\n" \
         "#\n" \
         "# Blucherry system includes two equivalent servers. Each server is connected\n" \
         "# to the bluecherry (internal) network via device DEVICE_NAME defined in the\n" \
         "# config file section marked as [INTERNAL].\n" \
         "#\n" \
         "# At any given time, only one server should be connected to the external network\n" \
         "# via device DEVICE_NAME defined in the config file section marked as [EXTERNAL].\n" \
         "# This connection has one or multiple ip-addresses (IPADDR=, IPADDR1=, ... , IPADDRN=).\n" \
         "# For example, using multiple ip-addresses may be required to logically group devices\n" \
         "# on the client side, or other porposes.\n" \
         "#\n" \
         "# The server that has an active external network connection is the MAJOR;\n" \
         "# the other server is MINOR. These servers must have the ip-adresses IPADDR_MAJOR\n" \
         "# and IPADDR_MINOR defined in the config file section marked as [INTERNAL].\n" \
         "# Also in the same section it's necessary to define the ip-address IPADDR_RESERVED\n" \
         "# (required for reconfiguration the internal network when changing server roles).\n" \
         "# !!! NOTE !!!\n" \
         "# 1. All ip-addresses specified in the config file must be defined in\n" \
         "# 'ip-address/prefix' format (for example IPADDR=192.168.2.222/24).\n"\
         "#\n" \
         "# 2. The IPADDR_MAJOR, IPADDR_MINOR and IPADDR_RESERVED values must be\n" \
         "# the same on both servers, respectively: the IPADDR_MAJOR value on the one server\n" \
         "# is qual to the IPADDR_MAJOR on the other server, and so on.\n" \
         "\n" \
         "[INTERNAL]\n" \
         "DEVICE_NAME=               # for example DEVICE_NAME=enp2s0\n" \
         "IPADDR_MAJOR=              # for example IPADDR_MAJOR=192.168.2.222\n" \
         "IPADDR_MINOR=              # for example IPADDR_MINOR=192.168.2.221\n" \
         "IPADDR_RESERVED=           # for example IPADDR_RESERVED=192.168.223\n" \
         "\n" \
         "IPADDR_MAJOR=                       # for example =192.168.2.222\n" \
         "IPADDR_MINOR=                       # for example =192.168.2.221\n" \
         "IPADDR_RESERVED=                    # for example =192.168.2.223\n" > $CONFIG_FILE


    ################ TO DO ###############
    echo -e "CONFIG FILE CONTENT" > $CONFIG_FILE
    
    exit 1
fi


# Scamm
PARAMETERS=$(./scan_config_file.sh $CONFIG_FILE)

if [[ $? > 0 ]]
then
    exit 2
fi



while [[ $PARAMETERS != "" ]]
do
    SECTION=$(./get_config_last_section.sh "$PARAMETERS")
    
    if [[ $? > 0 ]]
    then
        break
    fi
    
    SECTION_NAME=${SECTION%]*}
    SECTION_NAME=${SECTION_NAME#*[}
    
    
    case "$SECTION_NAME" in

        "EXTERNAL" | "external" )
            echo EXTERNAL
        ;;
         
        "INTERNAL" | "internal" )
            echo INTERNAL
        ;;
        
        * )
            echo UNKNOWN
        ;;
    esac
        
    
    LENGTH=$(echo $PARAMETERS | wc -c)
    LENGTH_SECTION=$(echo $SECTION | wc -c)
    
    let offset=$LENGTH-$LENGTH_SECTION
    PARAMETERS=${PARAMETERS:0:$offset}
done


exit 0

EXTERNAL_IPADDRS=$(echo $PARAMETERS | grep -wo "IPADDR[0-9]*=[0-9.]*")
echo $EXTERNAL_IPADDRS

exit 0

FS_BACKUP=$IFS
IFS=" "

#INTERNAL_INTERFACE_NAME=$(echo $PARAMETERS | grep INTERNAL_INTERFACE_NAME)

#echo $PARAMETERS

#echo $INTERNAL_INTERFACE_NAME

PRINTOUT=$(echo $PARAMETERS | grep  EXTERNAL_IPADDR | grep  EXTERNAL_IPADDR | sed ':a;N;$!ba;s/\n/ /g')

let 'i=0'
for p in $PRINTOUT
do
    echo p$i: $p
    EXTERNAL_IPADDRS[$i]=$(echo ${p#*=})
    let 'i=i+1'

done


IFS=$IFS_BACKUP

echo ${EXTERNAL_IPADDRS[*]}

exit 0


INTERNAL_IPADDR_MAJOR=192.168.2.222
INTERNAL_IPADDR_MINOR=192.168.2.221
INTERNAL_IPADDR_RESERVED=192.168.223
INTERNAL_NETMASK=255.255.255.0
INTERNAL_PREFIX=24

EXTERNAL_INTERFACE_NAME=enp7s4

EXTERNAL_IPADDR=10.54.94.98
EXTERNAL_NETMASK=255.255.255.0
EXTERNAL_PREFIX=24

EXTERNAL_IPADDR1=10.54.94.99
EXTERNAL_NETMASK1=255.255.255.0
EXTERNAL_PREFIX1=24







exit 0
