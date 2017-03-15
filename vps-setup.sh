#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 0
fi

read -p "Do you want to add a new sudo user? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "What's the name of the new sudo user?"
	read user
	echo "The new sudo user will be sudo $user"

	# Creating new sudo user
	echo "Creating new sudo user"
	adduser $user
	usermod -aG sudo $user

	# Disabling root
	echo "Disabling root"
	passwd -l root
fi

# Updating
echo "Updating"
apt-get update -y
apt-get dist-upgrade -y
apt-get autoremove -y

# Installing openssh-server
echo "Installing openssh-server"
apt-get install -y openssh-server

read -p "Do you want to change your SSH port? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Which port do you want SSH to run on?"
	read port
	echo "The new SSH port will be $port"

	# Changing SSH port
	echo "Changing SSH port"
	sed -i -e "s/Port 22/Port $port/g" /etc/ssh/sshd_config
fi

read -p "Do you want to restrict SSH access to only certain users? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Which users do you want to have SSH access?"
	echo "Separate by spaces"
	read restrict
	echo "OK. Restricting SSH access to only $restrict"

        # Restricting SSH users
        echo "Restricting SSH to $restrict"
        echo "AllowUsers $restrict" >> /etc/ssh/sshd_config
fi

# UFW setup
echo "Modifying and enabling UFW"
ufw allow $port
ufw enable

# fail2ban setup
echo "Installing and modifying fail2ban"
apt-get install -y fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i -e 's/bantime\ \ \=\ 600/bantime\ \ \=\ 604800/g' /etc/fail2ban/jail.local
systemctl restart fail2ban

# Creating swap
echo "How many GB do you want your swap to be?"
read swap
GB="G"
swap="$swap$GB"
echo "Your swap will be $swap"

echo "Creating swap"
fallocate -l $swap /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Installing new packages
apt-get install -y htop iotop iftop

# Installing web packages
read -p "Install Apache2? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	apt-get install -y apache2
fi

read -p "...nginx? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	apt-get install -y nginx
fi

read -p "...php-fpm? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	apt-get install -y php-fpm
fi

echo "Finished!"

exit 0
