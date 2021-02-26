#!/bin/bash

#####################################################################################
# @author Anatoly Gaidai (see avgaidai.github.io)                                   #
#                                                                                   #
# This script checks format of specified ip-address and netmask value               #
# (if netmask is specified).                                                        #
#                                                                                   #
# Input                                                                             #
# Arg 1: 'IPADDR' is ip-address in format 'x.x.x.x/m' or 'x.x.x.x', where:          #
#        x -- ip-address octet (range valid values: 0-255);                         #
#        m -- netmask (range valid values: 0-32).                                   #
#                                                                                   #
# Output                                                                            #
# Script returns 0 if ip-address and its netmask (if specified) are valid,          #
# or prints out (to stderr) error message and returns one of following              #
# non-zero error codes:                                                             #
# 1 -- not enough script arguments;                                                 #
# 2 -- invalid argument format;                                                     #
# 3 -- invalid netmask value;                                                       #
# 4 -- invalid ip-address octet value.                                              #
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


# Checking number of script arguments
if [[ "$1" == "" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- Not enough script arguments!\n" \
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0" \
         "IPADDR$END_FORMATTING\n" \
         "\t $FONT_GREEN IPADDR$END_FORMATTING is ip-address" \
         "in format$FONT_GREEN 'x.x.x.x/m'$END_FORMATTING or" \
         "$FONT_GREEN 'x.x.x.x'$END_FORMATTING\n" \
         "\t  where x is octet of ip-address; m is netmask." 1>&2

    exit 1
    
fi

# Removing extra spaces
ARG=$(echo $1)

# Getting ip-address from script argument
IPADDR=$(echo $ARG | egrep -wo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")

# Validating argument format (argument must be represented by only one word)
let IPADDR_CNT=$(echo $IPADDR | wc -w)

if [[ "$IPADDR" == "" || "$IPADDR_CNT" -gt 1 ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- Invalid argument format: $FONT_YELLOW$1$END_FORMATTING!\n" \
         "\t- Script argument must have only one ip-address!"  1>&2

    exit 2
    
fi

# Getting netmask from script argument
let LENGTH_IPADDR=$(echo $IPADDR | wc -m)-1
ARG=$(echo ${ARG:$LENGTH_IPADDR})
NETMASK=$(echo $ARG | egrep "^/[0-9]{1,2}$")

if [[ "$NETMASK" != "" ]]
then

    let NETMASK=$(echo ${ARG#*/})
    
    # Validating netmask value
    if [[ "$NETMASK" -gt 32 ]]
    then
    
    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- Invalid netmask value: $FONT_YELLOW$NETMASK$END_FORMATTING!\n" \
         "\t- Range of valid values for netmask: 0-32" 1>&2

        exit 3

    fi

elif [[ "$ARG" != "" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- Invalid argument format: $FONT_YELLOW$1$END_FORMATTING!" 1>&2

    exit 2

fi


# Validating ip-address value
while [[ "$IPADDR" != "" ]]
do
    
    # Getting ip-address octet
    let OCTET=$(echo $IPADDR | grep -o "[0-9]*$")
 
    let LENGTH_OCTET=$(echo $OCTET | wc -m)
    let LENGTH_IPADDR=$(echo $IPADDR | wc -m)
    let OFFSET=$LENGTH_IPADDR-$LENGTH_OCTET

    IPADDR=$(echo ${IPADDR:0:$OFFSET})
    IPADDR=$(echo ${IPADDR%.*})

    # Validating octet value
    if [ "$OCTET" -gt 255 ]
    then
        
        echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
            "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
            "\t- Invalid format ip-address: $FONT_YELLOW$1$END_FORMATTING!\n" \
            "\t- Invalid octet: $FONT_YELLOW$OCTET$END_FORMATTING" 1>&2

        exit 4
    fi
    
done

# ip-address and its netmask (if specified) are valid
exit 0
