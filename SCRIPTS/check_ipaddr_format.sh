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


# Checking the number of script arguments
if [[ $1 == "" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- Not enough script arguments!\n" \
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0" \
         "IPADDR $END_FORMATTING\n" \
         "\t$FONT_GREEN IPADDR$END_FORMATTING is an ip-addresse" \
         "in the format$FONT_GREEN 'x.x.x.x/m'$END_FORMATTING or" \
         "$FONT_GREEN 'x.x.x.x'$END_FORMATTING\n" \
         "\t where x is octet of ip-address; m is netmask." 1>&2

    exit 1
    
fi

ARG=$1

# Getting ip-address from script arg
IPADDR=$(echo $ARG | egrep -o "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")

# Checking correct format arg (arg must be presents only string type)
let IPADDR_CNT=$(echo $IPADDR | wc -l)

if [[ $IPADDR == "" || $IPADDR_CNT > 1 ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- Incorrect format ip-address: $FONT_ITALIC$FONT_YELLOW$1$END_FORMATTING!" 1>&2

    exit 1
    
fi

LENGTH_ARG=$(echo $IPADDR | wc -m)
let LENGTH_IPADDR=$LENGTH_IPADDR-1
ARG=$(echo ${ARG:$LENGTH_IPADDR})

echo $IPADDR

while [[ $IPADDR != "" ]]
do
    OCTET=$(echo $IPADDR | grep -o "[0-9]*$")
    echo $OCTET
    let LENGTH_OCTET=$(echo $OCTET | wc -m)
    let LENGTH_IPADDR=$(echo $IPADDR | wc -m)
    let OFFSET=$LENGTH_IPADDR-$LENGTH_OCTET

    IPADDR=$(echo ${IPADDR:0:$OFFSET})
    IPADDR=$(echo ${IPADDR%.*})

    sleep 1

done

exit 0





NETMASK=$(echo $ARG | egrep "^/[0-9]{1,2}$")

if [[ $NETMASK != "" ]]
then
    let NETMASK=$(echo ${ARG#*/})
fi


echo $IPADDR $NETMASK

exit 0
SECTION=$(echo $PARAMETERS | grep -o "\[[A-Za-z0-9._-]*\][^\[]*$")

if [[ $SECTION == "" ]]
then
    
    echo -e "Not such a section!" 1>&2
    exit 2
    
fi

echo $SECTION

exit 0
