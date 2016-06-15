bash-scripts is a collection of shell and bash scripts

wordpress-install.sh
-----

Based on https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-16-04

This script installs WordPress and all prerequisites. It sets up and 
configures Apache and MySQL to work with WordPress; including a WordPress 
database and system user. Passwords for the MySQL root user, MySQL 
wordpressuser, and system wordpress user will be stored in root protected 
text files in the newly created wordpress-passwords directory. 

Packages installed are:

	apache2, mysql-server, php, libapache2-mod-php, phpmcrypt, php-mysql, 
	php-curl, php-gd, php-mbstring, php-xml, php-xmlrpc 

PLEASE NOTE:

 - MUST be ran as root
 - Only works on Ubuntu Server 16.04 LTS
 - The WordPress install is from WordPress' own latest.tar.gz
 - If the script fails, or WordPress doesn't end up working try running the 
companion wordpress-purge.sh script

wordpress-purge.sh
-----

This script purges all packages installed from the wordpress-install.sh 
script; including ALL MySQL and PHP packages. It also purges ALL MySQL 
databases/files, ALL Apache directories/files, the wordpress system user, 
and the /var/www/html directory.

PLEASE NOTE:

 - MUST be ran as root
 - Only works on Ubuntu Server 16.04 LTS

ppa.sh
-----

This script lists all PPAs installed on Ubuntu.

installed-packages.sh
-----

This script lists packages that have been installed on Ubuntu post-install. 
It excludes packages that come pre-installed on Ubuntu, or were installed from 
Ubuntu Server's "Software selection" installation step. Only tested on 
Ubuntu 14 and 16.
