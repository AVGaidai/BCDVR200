#!/bin/bash

#####################################################################################
# @author Anatoly Gaidai (see avgaidai.github.io)                                   #
#                                                                                   #
# This script gets last section from specified config (list of sections).           #
#                                                                                   #
# Input                                                                             #
# Arg 1: 'CONFIG' is list of sections, each containing set of parameters            #
#        with their values.                                                         #
#                                                                                   #
# Output                                                                            #
# Script returns 0 and prints out last section from config if script                #
# is successfully executed, or prints out error message (to stderr)                 #
# and returns one of following non-zero error codes:                                #
# 1 -- not enough script arguments;                                                 #
# 2 -- section in config not found.                                                 #
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
if [[ $1 == "" ]]
then

    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- Not enough script arguments!\n" \
         "\t- Script launch format:$FONT_BOLD$FONT_GREEN $0" \
         "\"CONFIG\" $END_FORMATTING\n" \
         "\t $FONT_GREEN CONFIG$END_FORMATTING is sectioned string" \
         "of parametes with their values." 1>&2

    exit 1
    
fi

CONFIG=$1

# Getting last section of config
SECTION=$(echo $CONFIG | grep -o "\[[A-Za-z0-9._-]*\][^\[]*$")

if [[ $SECTION == "" ]]
then
    
    echo -e " [$FONT_BOLD$FONT_YELLOW WARNING $END_FORMATTING]:" \
         "$FONT_BOLD$FONT_RED $0$END_FORMATTING:\n" \
         "\t- Section in config not found!" 1>&2

    exit 2
    
fi

# Removing extra spaces
echo $SECTION

exit 0
