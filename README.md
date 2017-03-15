bash-scripts is a collection of shell and bash scripts

7z-make.sh
-----
Best compression via 7z.

Run with 7zmk file.txt or 7zmk directory

7z-dir.sh
-----
7zs all files and directories in the present working directory individually.

Run with 7zd (nothing else)

7z-encrypt.sh
-----
Best compression via 7z. Also encrypts the file or directory.

Run with 7ze file.txt password or 7ze directory password

7z-encrypt-dir.sh
-----
7zs all files and directories in the present working directory individually. 
Also encrypts the files or directories.

Run with 7zed password (nothing else).

apache-visits.sh
-----
Lists most to least visits of unique apache2 IP addresses.

nextcloud-install.sh
-----
Installs and configures latest Nextcloud release. Includes:
 - Generating 12-character random passwords for MySQL root, MySQL nextcloud, and Nextcloud admin
 - MySQL secure setup
 - Configuring file and directory permissions for Nextcloud
 - Creating Nextcloud Apache conf
 - Configuring Nextcloud Apache conf based on input
 - Configuring Nextcloud config.php

packages-installed.sh
-----
Lists all packages that have been installed post-installation. Excludes 
packages that come pre-installed, or were installed from Ubuntu's "Software 
selection" installation step. Only tested on Ubuntu 14 and 16.

rand12
-----
Generates a random 12 character password.

vps-setup.sh
-----
Sets up and secures personal DigitalOcean VPSs. Includes:
 - adding a new sudo user (optional)
 - disabling root (optional)
 - updates
 - installing openssh-server
 - changing the SSH port (optional)
 - restricting SSH access based on user (optional)
 - allowing the new SSH port through UFW (if you chose not to change the SSH
port you will need manually allow a different port though UFW)
 - enabling UFW
 - installing and configuring fail2ban
 - creating and configuring a new swapfile as /swapfile and appending it to
fstab
 - installing htop, iotop, and iftop
 - installing apache2 (optional)
 - installing nginx (optional)
 - installing php-fpm (optional)

vps-swap.sh
-----
Creates and configures a new swapfile as /swapfile and appends fstab.

wordpress-install.sh
-----
Based on https://www.digitalocean.com/community/tutorials/how-to-install-wordpr$

wordpress-install.sh installs WordPress and all prerequisites. It sets up and configures 
Apache and MySQL to work with WordPress; including a WordPress database and 
system user. Passwords for the MySQL root user, MySQL wordpressuser, and 
system wordpress user will be stored in root protected text files in the newly
created wordpress-passwords directory.

Packages installed are:

        apache2, mysql-server, php, libapache2-mod-php, phpmcrypt, php-mysql,
        php-curl, php-gd, php-mbstring, php-xml, php-xmlrpc

PLEASE NOTE:

 - Only works on Ubuntu Server 16.04 LTS
 - The WordPress install is from WordPress' own latest.tar.gz
 - If the script fails, or WordPress doesn't end up working try running the
companion wp-purge script

wordpress-purge.sh
-----
wordpress-purge.sh purges all packages installed from the wpins script; including ALL 
MySQL and PHP packages. It also purges ALL MySQL databases/files, ALL Apache 
directories/files, the wordpress system user, and the /var/www/html directory.
PLEASE NOTE: Only works on Ubuntu Server 16.04 LTS.

ytdlmp3 
-----
Downloads mp3s from YouTube, SoundCloud, etc., and only requires a URL.

Run with youtube-dl-mp3 URL.com

zip-make.sh
-----
Short command for zipping files.

Run with zipmk file.txt or zipmk directory

zip-dir.sh
-----
Zips all files and directories in the present working directory individually.

Run with zipd (nothing else)

zip-zero-dir.sh
-----
Short command for zipping files. No compression, simply zips files.

Run with zip0mk file.txt or zip0mk directory

zip-zero-make.sh
-----
Zips all files and directories in the present working directory individually. 
No compression, simply zips files.

Run with zip0d (nothing else)
