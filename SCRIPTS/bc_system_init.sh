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



#function internal_section_parser {}



function other_section_parser {

    if [[ $1 == "" || $2 == "" ]]
    then 
        
         echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED $0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- Not enough function arguments!\n" \
            "\t- Function invoke format:$FONT_BOLD$FONT_GREEN $FUNCNAME" \
            "\"SECTION_NAME\" \"SECTION_BODY\"$END_FORMATTING\n" \
            "\t$FONT_GREEN SECTION_NAME$END_FORMATTING is a NAME of" \
            "the config file section."
            "\t$FONT_GREEN SECTION_BODY$END_FORMATTING is a body of" \
            "the config file section." 1>&2
    
        return 1
    fi

    section_name=$1
    section_body=$2
    #echo $section_body
    device=$(echo $section_body | grep -wo "DEVICE_NAME=[A-Za-z0-9_-]*[ \t]*")
    ipaddrs_list=$(echo $section_body | egrep -wo "IPADDR[0-9]*=[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}[ \t]*")
    
    echo $device
    
    if [[ $device == "" ]]
    then
        return 2
    fi
    
    # Getting DEVICE_NAME parameter value
    device=$(echo ${device#*DEVICE_NAME=})
    
    # Checking device availability
    result=$(nmcli device | awk '{print $1}' | grep -wo $device)
  
    if [[ $result == "" ]]
    then
    ######## TO DO ##########
        echo -e "No such $device device!"
        return 3
    fi
    
    let i=0
    unset ipaddrs
    
    while [[ $ipaddrs_list != "" ]]
    do

        ipaddr=$(echo $ipaddrs_list | grep -wo "IPADDR[0-9]*=[0-9./]*$")
      
        length=$(echo $ipaddrs_list | wc -c)
        length_ipaddr=$(echo $ipaddr | wc -c)
        let offset=$length-$length_ipaddr

        ipaddrs_list=${ipaddrs_list:0:$offset}

        # Getting IPADDR parameter value
        ipaddrs[$i]=$(echo ${ipaddr#*=})
        echo $ipaddr_value
        
        # Checking correctness of the ip-address and netmask format
        #result=$(./check_ipaddr_format.sh $ipaddr_value)
        
        let i=i+1
        
    done
    
    echo 0: ${ipaddrs[0]}
    echo 1: ${ipaddrs[1]}
    
    return 0
}





CONFIG_FILE="bc_system.cfg"

# Checking for a config file.
# If the config file doesn't exist it will be created,
# but without parameters values, you need to set them yourself.
if [[ ! -f $CONFIG_FILE ]]
then
    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- No such $FONT_INTALIC$FONT_YELLOW$CONFIG_FILE$END_FORMATTING!\n" \
         "NOTE: The config file will be automatically created in the" \
         "$FONT_ITALIC$FONT_YELLOW$PWD$END_FORMATTING directory. It must be filled" \
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
         "#\n" \
         "# Optional config file section. This section is marked as [OPTIONAL]. It is defined,\n" \
         "# then you need to include to it and define the following parameters: DEVICE_NAME,\n" \
         "# IPADDR (if necessary IPADDR1, IPADDR2 etc). Optional section can be defined\n" \
         "# multiple times in the config file.\n" \
         "#\n" \
         "# !!! NOTE !!!\n" \
         "# 1. All ip-addresses specified in the config file must be defined in\n" \
         "# 'ip-address/prefix' format (for example IPADDR=192.168.2.222/24)!\n"\
         "#\n" \
         "# 2. The IPADDR_MAJOR, IPADDR_MINOR and IPADDR_RESERVED values must be\n" \
         "# the same on both servers, respectively: the IPADDR_MAJOR value on the one server\n" \
         "# is qual to the IPADDR_MAJOR on the other server, and so on!\n" \
         "#\n" \
         "# 3. All DEVICE_NAME values must be unique for each section within the config file!\n" \
         "#\n" \
         "\n" \
         "[INTERNAL]\n" \
         "DEVICE_NAME=               # for example DEVICE_NAME=enp2s0\n" \
         "IPADDR_MAJOR=              # for example IPADDR_MAJOR=192.168.2.222/24\n" \
         "IPADDR_MINOR=              # for example IPADDR_MINOR=192.168.2.221/24\n" \
         "IPADDR_RESERVED=           # for example IPADDR_RESERVED=192.168.223/24\n" \
         "\n" \
         "[EXTERNAL]\n" \
         "DEVICE_NAME=               # for example DEVICE_NAME=enp7s4\n" \
         "IPADDR=                    # for example IPADDR=10.54.94.98/24\n" \
         "\n" \
         "# If necessary, you can define in this section IPADDR1, IPADDR2 etc.\n" \
         "\n" > $CONFIG_FILE
    
    exit 1
fi


# Scan
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

    SECTION_BODY=$(echo ${SECTION#*]})
        
    case "$SECTION_NAME" in

        "EXTERNAL" | "external" )
            other_section_parser "$SECTION_NAME" "$SECTION_BODY"
        ;;
         
        "INTERNAL" | "internal" )
            echo INTERNAL
            
        ;;

        "OPTIONAL" | "optional" )
            other_section_parser "$SECTION_NAME" "$SECTION_BODY"
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
