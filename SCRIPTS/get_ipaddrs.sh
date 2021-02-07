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
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0 INTERFACE_NAME$END_FORMATTING\n" \
         "\t- Dependencies:$FONT_BOLD$FONT_BLUE nerwork-scripts$END_FORMATTING\n" \
         "\t- Path to 'ifcfg-<interface-name>' files:" \
         "$FONT_ITALIC$FONT_BLUE/etc/sysconfig/network-scripts$END_FORMATTING" 1>&2

    exit 1
    
fi


INT_NAME=$1
PATH_TO_IFCFG=/etc/sysconfig/network-scripts

PARAMETERS=$(./get_config_file_parameters.sh $PATH_TO_IFCFG/ifcfg-$INT_NAME)

if [[ $? > 0 ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- No such interface '$INT_NAME'!\n" \
         "\t- Path to 'ifcfg-<interface-name>' files:" \
         "$FONT_ITALIC$FONT_BLUE/etc/sysconfig/network-scripts$END_FORMATTING" 1>&2
    
    exit 2
        
fi

IFS_BACKUP=$IFS
IFS=" \t\n"
IPADDRS=$(echo $PARAMETERS | grep IPADDR)
PREFIXES=$(echo $PARAMETERS | grep PREFIX)
NETMASKS=$(echo $PARAMETERS | grep NETMASK)
IFS=$IFS_BACKUP

exit 0

for ipaddr in $IPADDRS 
do

    suffix=$(echo ${ipaddr#IPADDR*})
    suffix=$(echo ${suffix%=*})
    ipaddr=$(echo ${ipaddr#*=})

        
#    prefix=$(echo $PREFIXES | grep -o PREFIX$suffix=[0-9.]*)
    netmask=$(echo $NETMASKS | grep -wo  "NETMASK$suffix=[0-9.]*")
    echo $netmask
    if [[ $prefix == "" ]]
    then

        if [[ $netmask == "" ]]
        then

            echo -e " [$BOLD_FONT$FONT_YELLOW WARNING\033[0m ]: $FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
                 "$FORNT_ITALIC$FONT_BLUE$PATH_TO_IFCFG/ifcfg-$INT_NAME$END_FORMATTIN:\n" \
                 "\tparameters$BOLD_FONT$BLUE_FONT PREFIX$suffix$END_FORMATTING or" \
                 "$BOLD_FONT$BLUE_FONT NETMASK$suffix$END_FORMATTING for" \
                 "$BOLD_FONT$BLUE_FONT IPADDR$suffix=$ipaddr$END_FORMATTING not found!" \
                 "NETMASK$suffix\n"
            
        fi
    fi
       
    echo IPADDR$suffix=$ipaddr $prefix $netmask
             
    
done

              
exit 0
