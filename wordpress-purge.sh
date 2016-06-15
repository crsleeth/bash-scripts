#!/bin/bash

echo -e "This script purges all packages installed from the \
wordpress-install.sh script; including ALL MySQL and PHP packages. It also \
purges ALL MySQL databases/files, ALL Apache directories/files, the wordpress \
system user, and the /var/www/html directory."

read -p "Do you want to continue? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	exit 0
fi

read -p "Do you want to purge the auto-generated MySQL and system passwords \
in the wordpress-passwords directory? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	echo "Purging auto-generated passwords..."
	rm -Rf ./wordpress-passwords
fi

echo "Purging packages..."
apt-get purge apache2 *mysql* *php* -y
apt-get autoremove -y
apt-get autoclean

echo "...MySQL leftovers..."
rm -Rf /etc/mysql
rm -Rf /var/lib/mysql*

echo "...Apache leftovers..."
rm -Rf /etc/apache2

echo "...the wordpress system user..."
deluser wordpress

echo ".../var/www/html wordpress leftovers..."
rm -Rf /var/www/html/*
rm -Rf /var/www/html/.*

echo "Finished! I recommend rebooting now."

exit 0

