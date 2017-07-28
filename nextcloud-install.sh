#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 1
fi

echo "This script was tested on Ubuntu Server 16.04.2 LTS 64-bit running on Proxmox VE 4.4"

echo "Installing updates"
apt update

echo "Generating two passwords for the users MariaDB nextcloud and Nextcloud admin"
echo "IMPORTANT! You can view these passwords after installation in the nextcloud-passwords folder as root"
read -p "Continue? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
	exit 1
fi
mkdir -m 600 nextcloud-passwords
openssl rand -base64 12 > nextcloud-passwords/"mariadb-nextcloud.txt"
openssl rand -base64 12 > nextcloud-passwords/"nextcloud-admin.txt"
mariadbnextcloud=$(cat nextcloud-passwords/mariadb-nextcloud.txt)
nextcloudadmin=$(cat nextcloud-passwords/nextcloud-admin.txt)

echo "Installing packages"
# Install packages
apt install -y apache2 mariadb-server libapache2-mod-php7.0 php7.0-gd php7.0-json php7.0-mysql php7.0-curl php7.0-mbstring php7.0-intl php7.0-mcrypt php-imagick php7.0-xml php7.0-zip

echo "Creating nextcloud MariaDB database"
mysql -e "CREATE DATABASE nextcloud;"
echo "Creating MariaDB nextcloud user with nextcloud database privileges"
mysql -e "GRANT ALL ON nextcloud.* to 'nextcloud'@'localhost' IDENTIFIED BY '$mariadbnextcloud';"
echo "Reloading privileges"
mysql -e "FLUSH PRIVILEGES;"

echo "Downloading and extracting latest Nextcloud"
wget -O /tmp/latest.tar.bz2 https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xjf /tmp/latest.tar.bz2 -C /var/www
rm /tmp/latest.tar.bz2

echo "Configuring permissions"
# Source: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-nextcloud-on-ubuntu-16-04
mkdir /var/www/nextcloud/data
mkdir /var/www/nextcloud/assets
mkdir /var/www/nextcloud/updater
find /var/www/nextcloud/ -type f -print0 | xargs -0 chmod 640
find /var/www/nextcloud/ -type d -print0 | xargs -0 chmod 750
chmod 755 /var/www/nextcloud
chown -R root:www-data /var/www/nextcloud/
chown -R www-data:www-data /var/www/nextcloud/apps/
chown -R www-data:www-data /var/www/nextcloud/assets/
chown -R www-data:www-data /var/www/nextcloud/config/
chown -R www-data:www-data /var/www/nextcloud/data/
chown -R www-data:www-data /var/www/nextcloud/themes/
chown -R www-data:www-data /var/www/nextcloud/updater/
chmod +x /var/www/nextcloud/occ
chmod 640 /var/www/nextcloud/.htaccess
chown root:www-data /var/www/nextcloud/.htaccess

echo "Creating nextcloud Apache conf"
echo "<VirtualHost *:80>

  DocumentRoot /var/www/nextcloud

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  Alias / "/var/www/nextcloud/"

  <Directory /var/www/nextcloud/>
    Options +FollowSymlinks
    AllowOverride All

    <IfModule mod_dav.c>
      Dav off
    </IfModule>

    SetEnv HOME /var/www/nextcloud
    SetEnv HTTP_HOME /var/www/nextcloud
  </Directory>
</VirtualHost>" > /etc/apache2/sites-available/nextcloud.conf

read -p "Does your Nextcloud have a domain? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
        domain=yes
	read -p "Enter your Nextcloud's domain: " nextclouddomain
	echo "Adding your domain $nextclouddomain to the nextcloud Apache conf"
        # Insert ServerName at line 2
        sed -i "2i \  ServerName $nextclouddomain" /etc/apache2/sites-available/nextcloud.conf
else
        echo "Since your Nextcloud does not have a domain, ServerName in the nextcloud Apache conf will be left out."
        echo "In the future you can add ServerName to /etc/apache2/sites-available/nextcloud.com line 2 to fix this."
fi

echo "Enabling nextcloud website and restarting Apache"
a2dissite 000-default
a2ensite nextcloud
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
systemctl restart apache2

echo "Setting up Nextcloud"
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud" --database-user "nextcloud" --database-pass "$mariadbnextcloud" --admin-user "admin" --admin-pass "$nextcloudadmin"

echo "Removing index.php from URLs aka pretty URLs"
sed -i '$ d' /var/www/nextcloud/config/config.php
echo "  'htaccess.RewriteBase' => '/'," >> /var/www/nextcloud/config/config.php
echo ");" >> /var/www/nextcloud/config/config.php
chmod g+w /var/www/nextcloud/.htaccess
sudo -u www-data /var/www/nextcloud/occ maintenance:update:htaccess
chmod g-w /var/www/nextcloud/.htaccess

echo "Adding IP address to trusted domains"
# Get IP address
ipaddress=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
# Create backup of config.php
cp /var/www/nextcloud/config/config.php /var/www/nextcloud/config/config.php.bak
# Insert at line 8 IP address
sed -i "8i \    1 => '$ipaddress'," /var/www/nextcloud/config/config.php

if [ domain=yes ]
then
	echo "Adding your domain $nextclouddomain to trusted domains"
        # Create backup of config.php
        cp /var/www/nextcloud/config/config.php /var/www/nextcloud/config/config.php.bak
        # Insert at line 9 domain
        sed -i "9i \    2 => '$nextclouddomain'," /var/www/nextcloud/config/config.php
fi

echo "Restarting Apache one last time"
systemctl restart apache2

echo "Finished! You should be able to access Nextcloud by navigating to $ipaddress in your web browser."
echo "REMINDER: Use 'admin' and the password in nextcloud-passwords/nextcloud-admin.txt to login."

exit 0
