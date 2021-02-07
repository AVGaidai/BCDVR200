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


if [[ ! -f $CONFIG_FILE ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- No such $FONT_INTALIC$FONT_BLUE$CONFIG_FILE$END_FORMATTING!\n" \
         "NOTE: The config file will be automatically created in the" \
         "$FONT_ITALIC$FONT_BLUE$PWD$END_FORMATTING directory. It must be filled" \
         "in according to the instructions specified in the comments to the" \
         "config file." 1>&2

    ################ TO DO ###############
    echo -e "CONFIG FILE CONTENT" > $CONFIG_FILE
    
    exit 1
    
fi


PARAMETERS=$(./scan_config_file.sh $CONFIG_FILE)

if [[ $? > 0 ]]
then
    
    exit 2

fi


EXTERNAL_IPADDRS=$(./get_elements_by_pattern.sh "$PARAMETERS" EXTERNAL_IPADDR)
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
