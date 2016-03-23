#!/bin/bash

# Bash formatting.
RESTORE="\e[0m"		# Resets all formatting.
BOLD="\e[1m"		# Bold.
LBLUE="\e[94m"		# Light Blue foreground colour.
LGREEN="\e[92m"		# Light Green foreground colour.
LRED="\e[91m"		# Light Red foreground colour.
LMAGENTA="\e[105m"	# Light magenta foreground colour.
# End bash formatting.

# Check if any parameters were passed.
if [ $# == 0 ]; then
	echo -e "Usage: ${BOLD}addhost.sh${RESTORE} ${LBLUE}<domain>"${RESTORE}
	exit 1;
fi

# Check if more than 1 parameter was passed.
if [ $# -gt 1 ]; then
	echo -e ${LRED}"Sorry, but I received too many parameters, I only expected 1."${RESTORE}
	exit 1;
fi

# Check if user is root or not.
if [ "$(whoami)" != 'root' ]; then
        echo -e ${LRED}"Sorry, but you must be root to create a host map."${RESTORE}
        exit 1;
fi

# Define constants.
domain="${1}"		# The first parameter passed in - which should be the domain.
ip="192.168.1.73"	# The IP address to add to hosts file.
#ip="127.0.0.1"		# The IP address to add to hosts file.

# Make sure the user wants to continue.
echo -e "You are about to add a host of ${LBLUE}${domain}${RESTORE}."
read -p "Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Finally, add the domain to the hosts file
	# This part from http://thecodecave.com/2010/11/03/adding-a-line-to-etchosts-via-bash/
	SUCCESS=0			# All good programmers use Constants
	#domain=$1
	needle=www.${domain}		# Fortunately padding & comments are ignored
	hostline="${ip} ${domain} www.${domain}"
	filename=/etc/hosts

	# Determine if the line already exists in /etc/hosts
	grep -q "${needle}" "${filename}"	# -q is for quiet. Shhh...

	# Grep's return error code can then be checked. No error=success
	if [ $? -eq ${SUCCESS} ]
	then
		echo -e ${LRED}"Domain ${LBLUE}${domain}${LRED} is already present in the hosts file."${RESTORE}
	else
		# If the line wasn't found, add it using an echo append >>
		echo "${hostline}" >> "${filename}"
		echo -e ${LGREEN}"${LBLUE}${domain}${LGREEN} has been added to the hosts file."${RESTORE}
	fi
else
	echo -e ${LRED}"Adding host cancelled."${RESTORE}
fi
