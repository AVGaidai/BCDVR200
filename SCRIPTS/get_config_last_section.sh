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
         "\"PARAMETERS\" $END_FORMATTING\n" \
         "\t $FONT_GREEN PARAMETERS$END_FORMATTING is a sectioned string" \
         "of parametes with their values." 1>&2

    exit 1
    
fi

PARAMETERS=$1

# Rule for section name TO Do
SECTION=$(echo $PARAMETERS | grep -o "\[[A-Za-z0-9._-]*\][^\[]*$")

if [[ $SECTION == "" ]]
then
    
    echo -e "Not such a section!" 1>&2
    exit 2
    
fi

echo $SECTION

exit 0
