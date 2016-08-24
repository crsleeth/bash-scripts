#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 0
fi

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

echo "Finished! Reboot to apply."

exit 0
