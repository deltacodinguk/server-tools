#!/bin/bash

if [ $# == 0 ]; then
	echo "Usage: ./removesite <domain> [-f]"
	exit 1;
fi

if [ "$(whoami)" != 'root' ]; then
        echo "Sorry, you must be root to remove a virtual host."
        exit 1;
fi

# Remove the site from apache
a2dissite $1
service apache2 reload

# Remove the site config
rm -rf /etc/apache2/sites-available/$1.conf

# Remove the line from hosts
sed -i "/www.$1/ d" /etc/hosts

# Delete the site files (or rename the folder)
# Look for the delete option

if [ "$2" != "-f" ]; then
	echo "Retaining website files"
	if [ ! -d "/var/www/vhosts/$1-retired" ]; then
		# Rename the virtual host folder to indicate it's retired
		mv /var/www/vhosts/$1 /var/www/vhosts/$1-retired
		echo "The file folder has been renamed to end with -retired."
	else
		echo "Could not rename the folder - /var/www/vhosts/$1-retired already exists"
	fi
else
	rm -rf /var/www/vhosts/$1
	echo "The file folder has been deleted."
fi

echo "$1 has been removed from Apache's enabled sites"
echo "$1 has been removed from the hosts file"
echo "Don't forget to remove the database and site files."
