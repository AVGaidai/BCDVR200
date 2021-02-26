#!/bin/bash

#####################################################################################
# @author Anatoly Gaidai (see avgaidai.github.io)                                   #
#                                                                                   #
# This script gets useful content from config file (excluding line comment          #
# sterting with '#' character).                                                     #
#                                                                                   #
# Input                                                                             #
# Arg 1: 'CONFIG_FILE' is path to config file.                                      #
#                                                                                   #
# Output                                                                            #
# Script returns 0 and prints out useful content from specified                     #
# config file if script is successfully executed, or prints out (to stderr)         #
# error message and returns one of following non-zero error codes:                  #
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


# Checking number of script arguments
if [[ "$1" == "" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- Not enough script arguments!\n" \
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0" \
         "CONFIG_FILE$END_FORMATTING\n" \
         "\t $FONT_GREEN CONFIG_FILE$END_FORMATTING is path to" \
         "config file." 1>&2
         
    exit 1
    
fi

CONFIG_FILE="$1"

# Checking if config file exists
if [[ ! -f "$CONFIG_FILE" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED$0$END_FORMATTING:\n" \
         "\t- No such config file $FONT_YELLOW$CONFIG_FILE$END_FORMATTING!\n" 1>&2 

    exit 2
        
fi


# Printing useful content from config file
RESULT=$(cat $CONFIG_FILE | sed "s/\#.*//g" | sed "/^[ \t]*$/d")

# Removing extra spaces
echo $RESULT

exit 0
