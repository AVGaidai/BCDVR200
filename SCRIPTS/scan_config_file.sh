#!/bin/bash

#####################################################################################
# @author Anatoly Gaidai (see avgaidai.github.io)                                   #
#                                                                                   #
# This script gets all useful parameters from specified config file (excluding      #
# line comment sterting with '#' character).                                        #
#                                                                                   #
# Argument 1 -- $1 is path to config file (including his full name).                #
#                                                                                   #
# Script returns 0 and prints out all useful parameters obtained from the specified #
# config file if the script is successfully executed, or prints out (to stderr)     #
# error message and returns one of the following non-zero error codes:              #
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
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0 CONFIG_FILE_NAME$END_FORMATTING\n" 1>&2
         
    exit 1
    
fi

# Path to the config file
CONFIG_FILE=$1


# Checking if a config file exists
if [[ ! -f $CONFIG_FILE ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- File$FONT_ITALIC$FONT_BLUE$CONFIG_FILE$END_FORMATTING is not exist!\n" 1>&2 

    exit 2
        
fi


# Printing all useful parameters from the config file
RESULT=$(cat $CONFIG_FILE | sed "s/\#.*//g" | sed "/^[ \t]*$/d")

echo $RESULT

exit 0
