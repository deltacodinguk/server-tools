#!/bin/bash

# Start config values.
SITES_AVAILABLE="/etc/apache2/sites-available"	# This is where apache has the list of conf files for available sites.
DOCUMENT_ROOT="/var/www/vhosts"			# This is the location of the apache2 web files.
SERVER_ADMIN="hassan@philipemerson.com"		# This is the email address of the server admin.
MYSQL_USER="scriptbot"				# This is the main MySQL username of the server.
MYSQL_PASS="sp1d3rm4n"				# This is the main MySQL password of the server.
ME="hazrpg"					# This is your login username.
APACHE="www-data"				# This is the apache user/group name.
# End config values.

# Bash formatting.
RESTORE="\e[0m"		# Resets all formatting.
BOLD="\e[1m"		# Bold.
LBLUE="\e[94m"		# Light Blue foreground colour.
LGREEN="\e[92m"		# Light Green foreground colour.
LRED="\e[91m"		# Light Red foreground colour.
LMAGENTA="\e[95m"	# Light magenta foreground colour.
# End bash formatting.

# Check if any parameters were passed.
if [ $# == 0 ]; then
	echo -e "Usage: ${BOLD}addsite.sh${RESTORE} ${LBLUE}<domain>${RESTORE} ${LGREEN}[dbname/dbuser]${RESTORE} ${LMAGENTA}[dbpass]"${RESTORE}
	exit 1;
fi

# Check if only 2 parameters were passed.
if [ $# == 2 ]; then
	pass="`</dev/urandom tr -dc A-Za-z0-9 | head -c 32`"
	#echo -e ${LRED}"Sorry, but I only received ${LBLUE}<domain>${LRED} of ${LBLUE}${1}${LRED} and ${LGREEN}[dbname/dbuser]${LRED} of ${LGREEN}${2}${LRED}, you need a ${LMAGENTA}[dbpass]${LRED} too."${RESTORE}
	#exit 1;
fi

if [ $# == 3 ]; then
	pass="${3}"
fi

# Check if more than 3 parameters were passed.
if [ $# -gt 3 ]; then
	echo -e ${LRED}"Sorry, but I received too many parameters, I only expected 1 or 3."${RESTORE}
	exit 1;
fi

# Check if user is root or not.
if [ "$(whoami)" != 'root' ]; then
        echo -e ${LRED}"Sorry, but you must be root to create a new virtual host."${RESTORE}
        exit 1;
fi

# Define constants.
domain="${1}"	# The first parameter passed in - which should be the domain.
dbuser="${2}"	# The second parameter passed in - which should be the database name and/or username.
dbpass="${pass}"	# The second parameter passed in - which should be the database user's password.

# Make sure the user wants to continue.
if [ $# == 1 ]; then
	echo -e "You are about to add a new site ${LBLUE}${domain}${RESTORE}."
else
	echo -e "You are about to add a new site ${LBLUE}${domain}${RESTORE} with database/user ${LGREEN}${dbuser}${RESTORE} and password ${LMAGENTA}${dbpass}${RESTORE}."
fi
read -p "Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e "Creating new domain directories: ${LBLUE}${domain}${RESTORE}."
	mkdir -p ${DOCUMENT_ROOT}/${domain}/httpdocs
	mkdir -p ${DOCUMENT_ROOT}/${domain}/logs
	#cp -R /var/www/vhosts/skeleton /var/www/vhosts/${domain}
	echo -e ${LGREEN}"Created virtual host directory structure."${RESTORE}

	# Read the template up to the TPLEND marker into the TPL var
	IFS='' read -r -d '' TPL <<TPLEND
<VirtualHost *:80>
	ServerAdmin ${SERVER_ADMIN}
	DocumentRoot "${DOCUMENT_ROOT}/${domain}/httpdocs"
	ServerName ${domain}
	ServerAlias www.${domain}
	<Directory "${DOCUMENT_ROOT}/${domain}/httpdocs">
		Allowoverride All
		Order allow,deny
		Allow from all
		Require all granted
	</Directory>
	ErrorLog "${DOCUMENT_ROOT}/${domain}/logs/error_log"
	CustomLog "${DOCUMENT_ROOT}/${domain}/logs/access_log" common
</VirtualHost>
TPLEND
	echo "$TPL" > "${SITES_AVAILABLE}/${domain}.conf"
	echo -e ${LGREEN}"Created virtual host conf file."${RESTORE}

	# If another two parameters were passed, create the database.
	if [ $# == 3 -o ! -z ${pass} ]; then
		SCRIPT="CREATE DATABASE \`${dbuser}\`;
			CREATE USER '${dbuser}'@'localhost' IDENTIFIED BY '${dbuser}';
			GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,CREATE TEMPORARY TABLES,LOCK TABLES on \`${dbuser}\`.* TO '${dbuser}'@'localhost';"

		mysql -u ${MYSQL_USER} -p${MYSQL_PASS} -e "${SCRIPT}"

		#echo "${SCRIPT}"
		echo "Database ${dbuser}" > ${DOCUMENT_ROOT}/${domain}/database.txt
		echo "Username ${dbuser}" >> ${DOCUMENT_ROOT}/${domain}/database.txt
		echo "Password ${dbpass}" >> ${DOCUMENT_ROOT}/${domain}/database.txt
		echo -e ${LGREEN}"Created database. Details are in ${BOLD}${DOCUMENT_ROOT}/${domain}/database.txt${RESTORE}${LGREEN}."
	fi

	# Add the new site to apache
	a2ensite ${domain}
	service apache2 reload

	# Finally, add the domain to the hosts file
	# This part from http://thecodecave.com/2010/11/03/adding-a-line-to-etchosts-via-bash/
	SUCCESS=0			# All good programmers use Constants
	#domain=$1
	needle="www.${domain}"		# Fortunately padding & comments are ignored
	hostline="127.0.0.1 ${domain} www.${domain}"
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

	# Finally, change the owner of the site folder to apache (i.e. www-data).
	chown -R ${ME}:${APACHE} ${DOCUMENT_ROOT}/${domain}

	# Allow group users to write to the directory too, make it sticky too.
	chmod -R g+ws ${DOCUMENT_ROOT}/${domain}
else
	echo -e ${LRED}"Adding host cancelled."${RESTORE}
fi
