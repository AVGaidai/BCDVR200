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


# Following variables prefixed with  'FONT_' (and the END_FORMATTING variable) are
# escape sequences for formatting printout
FONT_BOLD="\033[1m"
FONT_ITALIC="\033[3m"

FONT_YELLOW="\033[33m"
FONT_RED="\033[31m"
FONT_BLUE="\033[34m"
FONT_GREEN="\033[32m"

END_FORMATTING="\033[0m"



# Used devices
USED_DEVICES=""

#function internal_section_parser {}



# Handling the EXTERNAL/OPTIONAL config file section
#
# This function ...
#
# Input:
#
#
# Output:
#
function other_section_handler {

    # Checking the number of function arguments
    if [[ "$1" == "" || "$2" == "" ]]
    then 
        
         echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- Not enough function arguments!\n" \
            "\t- The function invoke format:$FONT_BOLD$FONT_GREEN $FUNCNAME" \
            "\"SECTION_NAME\" \"SECTION_BODY\"$END_FORMATTING\n" \
            "\t $FONT_GREEN SECTION_NAME$END_FORMATTING is the NAME of" \
            "the config file section.\n" \
            "\t $FONT_GREEN SECTION_BODY$END_FORMATTING is the body of" \
            "the config file section." 1>&2
    
        return 1
        
    fi

    section_name=$1
    section_body=$2

    # Getting the DEVICE_NAME parameter
    device=$(echo $section_body | grep -wo "DEVICE_NAME=[A-Za-z0-9_-]*[ \t]*")
    
    if [[ "$device" == "" ]]
    then
    
        echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- No such the$FONT_YELLOW DEVICE_NAME$END_FORMATTING" \
            "parameter in the$FONT_YELLOW [$section_name]$END_FORMATTING"\
            "config file section!" 1>&2
        
        return 2
        
    fi
 
    # Getting the DEVICE_NAME parameter value
    device=$(echo ${device#*DEVICE_NAME=})
    
    # Checking device availability
    result=$(nmcli device | awk '{print $1}' | grep -wo $device)
  
    if [[ "$result" == "" ]]
    then
        
        echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- No such the$FONT_YELLOW $device$END_FORMATTING device!" 1>&2

        return 3
    fi

    # Checking the device for non-use
    result=$(echo $USED_DEVICES | grep -wo "$device")
     
    if [[ "$result" != "" ]]
    then
        
        echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- The $FONT_YELLOW$device$END_FORMATTING device" \
            "is already in use!" 1>&2

        return 4
    fi

    USED_DEVICES="$USED_DEVICES$device "

    # Getting a list of IP-addresses from the section
    ipaddrs_list=$(echo $section_body | egrep -wo "IPADDR[0-9]*=[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}[ \t]*")    

    let i=0
    unset ipaddrs
    
    # Checking each IP-addresses
    while [[ "$ipaddrs_list" != "" ]]
    do
        
        # Getting the last IP-address from the list
        ipaddr=$(echo $ipaddrs_list | grep -wo "IPADDR[0-9]*=[0-9./]*$")
        
        if [[ "$ipaddr" == "" ]]
        then
            break
        fi

        # Validating a format of the IP-address and its netmask 
        ./validate_ipaddr_format.sh $(echo ${ipaddr#*=})

        if [[ "$?" -gt 0 ]]
        then
            return 5
        fi
        
        # Getting the IPADDR parameter value
        ipaddrs[$i]=$(echo ${ipaddr#*=})

        let length=$(echo $ipaddrs_list | wc -c)
        let length_ipaddr=$(echo $ipaddr | wc -c)
        let offset=$length-$length_ipaddr

        ipaddrs_list=${ipaddrs_list:0:$offset}
                
        let i=i+1
        
    done
    
    # If the IPADDR parameter is not found in the config file section
    if [[ $i -eq 0 ]]
    then
    
        echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
            "\t- No such the$FONT_YELLOW IPADDR$END_FORMATTING" \
            "parameter in the$FONT_YELLOW [$section_name]$END_FORMATTING" \
            "config file section!" 1>&2

        return 6
    fi
        
    # Deleting the connection profile named '<SECTION NAME>-<ITS DEVICE>'
    con=$(nmcli connection | awk '{print $1}' | grep -wo $section_name-$device)
    
    if [[ "$con" != "" ]]
    then
        
        result=$(nmcli connection delete $con)
        
        if [[ "$?" -ne 0 ]]
        then
            
            echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
                "$FONT_BOLD$FONT_RED$0:$FUNCNAME$END_FORMATTING:\n" \
                "\t- The$FONT_YELLOW 'nmcli connection delete $con'$END_FORMATTING" \
                "command failed:\n" \
                "$FONT_BLUE$result$END_FORMATTING" 1>&2
  
            return 7
        fi
        
    fi

    # Creating the connection profile named '<SECTION NAME>-<ITS DEVICE>'

# To add IP-addresses list from the section to the connection profile
    con="$section_name-$device"
    result=$(nmcli connection add con-name $con type ethernet ifname $device)


    echo ${ipaddrs[*]}
    
    return 0
}


CONFIG_FILE="bc_system.cfg"

# Checking for a config file.
# If the config file doesn't exist it will be created,
# but without parameters values, you need to set them yourself.
if [[ ! -f "$CONFIG_FILE" ]]
then
    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- No such $FONT_YELLOW$CONFIG_FILE$END_FORMATTING!\n" \
         "NOTE: The config file will be automatically created in the" \
         "$FONT_YELLOW$PWD$END_FORMATTING directory. It must be filled" \
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
         "# Using multiple ip-addresses may be required to logically group devices\n" \
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


# Scanning config file and getting parameters 
PARAMETERS=$(./scan_config_file.sh $CONFIG_FILE)

if [[ "$?" -gt 0 ]]
then

    exit 2

fi


# Getting and handling each the config file section one by one
while [[ "$PARAMETERS" != "" ]]
do
    
    # Getting the config file last section
    SECTION=$(./get_config_last_section.sh "$PARAMETERS")
    
    if [[ "$?" > 0 ]]
    then
        break
    fi


    # Getting the config file section name
    SECTION_NAME=${SECTION%]*}
    SECTION_NAME=${SECTION_NAME#*[}

    # Getting the config file section body
    SECTION_BODY=$(echo ${SECTION#*]})
    
    # Handling the config file section
    case "$SECTION_NAME" in

        "EXTERNAL" | "external" | "OPTIONAL" | "optional" )
            other_section_handler "$SECTION_NAME" "$SECTION_BODY"
            
            if [[ "$?" -gt 0 ]]
            then
            
                echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
                    "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
                    "\t- Check the config file content!\n" \
                    "\t  Config file: $FONT_YELLOW$CONFIG_FILE$END_FORMATTING\n" \
                    "\t  Section:$FONT_YELLOW [$SECTION_NAME]$END_FORMATTING"  1>&2
                exit 3
            
            fi
        ;;
         
        "INTERNAL" | "internal" )
            echo INTERNAL
            
        ;;
        
        * )
            echo UNKNOWN
        ;;
        
    esac        

    let LENGTH=$(echo $PARAMETERS | wc -m)
    let LENGTH_SECTION=$(echo $SECTION | wc -m)
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
