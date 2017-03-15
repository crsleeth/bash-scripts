#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 1
fi

echo -e "wordpress-install.sh installs WordPress and all prerequisites. It sets up and \
configures Apache and MySQL to work with WordPress; including a WordPress \
database and system user. Passwords for the MySQL root user, MySQL \
wordpressuser, and system wordpress user will be stored in root protected \
text files in the newly created wordpress-passwords directory. 
Packages installed are:
\tapache2, mysql-server, php, libapache2-mod-php, phpmcrypt, php-mysql, 
\tphp-curl, php-gd, php-mbstring, php-xml, php-xmlrpc
PLEASE NOTE:
\t--Only works on Ubuntu Server 16.04 LTS
\t--The WordPress install is from WordPress' own latest.tar.gz
\t--If the script fails, or Wordpress doesn't end up working try running 
\t  the companion purge-wordpress-ubuntu-16.sh script"

read -p "Do you want to continue? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	exit 0
fi

# Generates three unique 12-character passwords for MySQL root, system wordpress user, and MySQL wordpress user
mkdir -m 600 wordpress-passwords
openssl rand -base64 12 > wordpress-passwords/"mysql-root-$(date +%m%d%Y-%H%M%S).txt"
openssl rand -base64 12 > wordpress-passwords/"system-wordpress-$(date +%m%d%Y-%H%M%S).txt"
openssl rand -base64 12 > wordpress-passwords/"mysql-wordpressuser-$(date +%m%d%Y-%H%M%S).txt"
mysqlroot=$(cat wordpress-passwords/mysql-root-*.txt)
systemwp=$(cat wordpress-passwords/system-wordpress-*.txt)
mysqlwpu=$(cat wordpress-passwords/mysql-wordpressuser-*.txt)

# LAMP required first
apt-get update -y
apt-get upgrade -y
debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysqlroot"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysqlroot"
apt-get install apache2 mysql-server php libapache2-mod-php php-mcrypt php-mysql -y

# Securing MySQL server with mysql_secure_installation
mysql -u root -p"$mysqlroot" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"$mysqlroot" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p"$mysqlroot" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
mysql -u root -p"$mysqlroot" -e "FLUSH PRIVILEGES;"

# Setting up wordpress system user
useradd -p $(openssl passwd -1 $systemwp) wordpress

# Step 1
mysql -u root -p"$mysqlroot" -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -u root -p"$mysqlroot" -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY '$mysqlwpu';"
mysql -u root -p"$mysqlroot" -e "FLUSH PRIVILEGES;"

# Step 2
apt-get install php-curl php-gd php-mbstring php-xml php-xmlrpc -y
systemctl restart apache2

# Step 3
sed -i '170i <Directory /var/www/html>' /etc/apache2/apache2.conf
sed -i '171i \\tAllowOverride All' /etc/apache2/apache2.conf
sed -i '172i </Directory>' /etc/apache2/apache2.conf
sed -i '173i \\' /etc/apache2/apache2.conf
a2enmod rewrite
systemctl restart apache2

# Step 4
curl -o /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz
tar xzvf /tmp/latest.tar.gz -C /tmp
touch /tmp/wordpress/.htaccess
chmod 660 /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/html
sudo rm /var/www/html/index.html

# Step 5
chown -R wordpress:www-data /var/www/html
chmod g+w /var/www/html/wp-content
chmod g+s /var/www/html/wp-content

# Removes wp-config.php default unique keys and salts
sed -i '/AUTH_KEY/d' /var/www/html/wp-config.php
sed -i '/SECURE_AUTH_KEY/d' /var/www/html/wp-config.php
sed -i '/LOGGED_IN_KEY/d' /var/www/html/wp-config.php
sed -i '/NONCE_KEY/d' /var/www/html/wp-config.php
sed -i '/AUTH_SALT/d' /var/www/html/wp-config.php
sed -i '/SECURE_AUTH_SALT/d' /var/www/html/wp-config.php
sed -i '/LOGGED_IN_SALT/d' /var/www/html/wp-config.php
sed -i '/NONCE_SALT/d' /var/www/html/wp-config.php

# Inserts your wp-config.php unique keys and salts
curl -s https://api.wordpress.org/secret-key/1.1/salt >> /tmp/wp-salt.txt
sed -i '48r /tmp/wp-salt.txt' /var/www/html/wp-config.php

# Removes wp-config.php MySQL default configs
sed -i '/DB_NAME/d' /var/www/html/wp-config.php
sed -i '/DB_USER/d' /var/www/html/wp-config.php
sed -i '/DB_PASSWORD/d' /var/www/html/wp-config.php

# Inserts your wp-config.php MySQL configs
sed -i "23i define('DB_NAME', 'wordpress');" /var/www/html/wp-config.php
sed -i "26i define('DB_USER', 'wordpressuser');" /var/www/html/wp-config.php
sed -i "29i define('DB_PASSWORD', '$mysqlwpu');" /var/www/html/wp-config.php
echo "define('FS_METHOD', 'direct');" >> /var/www/html/wp-config.php

# Clean up
rm /tmp/latest.tar.gz
rm -R /tmp/wordpress
rm /tmp/wp-salt.txt

echo "Finished!"

exit 0
