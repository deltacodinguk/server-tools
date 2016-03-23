#!/bin/bash

# Description of script.
# Copyright (C) 2014 Hassan Williamson - All Rights Reserved.
#
# Permission to copy and modify is granted.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Revised by		: Hassan Williamson
# Last revised		: 2014/11/20 @ 17:11
# Version		: 0.1

# Start config values.
INITIAL_DIR="`pwd`"			# We need to store our location because we will be switching it.
BASENAME=`basename $0`			# The name of the script (or name of symlink).
$1=32					# Length of password.
# End config values.

# Bash formatting.
RESTORE="\e[0m"		# Resets all formatting.
BOLD="\e[1m"		# Bold.
LBLUE="\e[94m"		# Light Blue foreground colour.
LGREEN="\e[92m"		# Light Green foreground colour.
LRED="\e[91m"		# Light Red foreground colour.
LMAGENTA="\e[105m"	# Light magenta foreground colour.
# End bash formatting.



# Check if any parameters were passed.
#if [ $# == 0 ]; then
#	echo -e "Usage: ${BOLD}${BASENAME}${RESTORE} ${LBLUE}<length>${RESTORE}"
#	echo -e "  e.g. 32"
#	exit 1;
#fi

# Check if too many parameters were passed.
if [ $# -gt 1 ]; then
	echo -e "${LRED}Sorry, but too many parameters were passed. Please check command usage by typing in ${BOLD}${BASENAME}${RESTORE}${LRED}.${RESTORE}"
	exit 1;
fi

# Check if user is root or not.
if [ "$(whoami)" != 'root' ]; then
	echo -e "${LRED}Sorry, you must be root to do this.${RESTORE}"
	exit 1;
fi

# Define constants.
length="${1}"	# The first parameter passed in - which should be...

# Make sure the user wants to continue.
echo -e "You are about to create a list of passwords."
read -p "Are you sure? " -n 1 -r	# Automatically continue if either y or n is pressed.
echo ""					# Enter a blank line.
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Do something here.
	# Thanks to: http://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
	date +%s | sha256sum | base64 | head -c 32 ; echo
	< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;
	openssl rand -base64 32
	tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1
	strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo
	< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c6
	dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev
	#</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c8; echo ""
	randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
	#randpw()
	date | md5sum
	</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c8; echo ""
	echo -e "${LGREEN}Created ... of ${BOLD}${INITIAL_DIR}/${param1}.conf${RESTORE}."
else
	# Display error message to user.
	echo -e ${LRED}"Opperation canceled."${RESTORE}
fi
