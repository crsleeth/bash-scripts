#!/bin/bash
if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 1
fi

echo "This script was tested on Ubuntu 16.04.4 LTS 64-bit"
echo "Before running this script please create any users in System Settings"
echo "Also, login to them AT LEAST ONCE"
echo "This script installs packages: tigervnc, xfce4"
read -p "Have you done the above steps? Continue? (Y/n): " -n 1
if [[ $REPLY =~ ^[Nn]$ ]]
then
	exit 1
fi

echo "Updating apt"
apt update -y
echo "Downloading tigervnc"
wget https://bintray.com/tigervnc/stable/download_file?file_path=ubuntu-16.04LTS%2Famd64%2Ftigervncserver_1.8.0-1ubuntu1_amd64.deb
for f in *tigervncserver*
	do mv "$f" "tigervncserver${f#*tigervncserver}"
done
echo "Installing packages"
apt install -y xfce4
# Install tigervnc deb and its missing depends
dpkg -i tigervncserver*.deb
apt install -f -y

x=1

read -p "Which user accounts do you want to setup vncserver for? Use space as a delimiter: " -a users
for i in "${users[@]}"
do
	echo "OK, setting up user $i vncserver"
	# Start and stop vncserver for user to create default configs
	su user -c "/usr/bin/vncserver"
	su user -c "/usr/bin/vncserver -kill :1"
	su user -c "/usr/bin/vncserver -kill :$x"

	# Disabled doesn't work with Ubuntu 14.04
	#runuser -l $i -c "/usr/bin/vncserver"
	#runuser -l $i -c "/usr/bin/vncserver -kill :1"
	#runuser -l $i -c "/usr/bin/vncserver -kill :$x"

	# Backup default xstartup, create working xfce4 replacement
	cp /home/$i/.vnc/xstartup /home/$i/.vnc/xstartup.bak
	echo -e "#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\n" > /home/$i/.vnc/xstartup
	chown -R $i:$i /home/$i/.vnc
	chmod +x /home/$i/.vnc/xstartup

	# Create systemd service
	echo -e "[Unit]\nDescription=TightVNC server for $i\nAfter=syslog.target network.target\n" > /etc/systemd/system/vncserver-$i.service
	echo -e "[Service]\nType=forking\nUser=$i\nPAMName=login\nPIDFile=/home/$i/.vnc/%H:$x.pid\nExecStartPre=-/usr/bin/vncserver -kill :$x > /dev/null 2>&1\nExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :$x\nExecStop=/usr/bin/vncserver -kill :$x\n" >> /etc/systemd/system/vncserver-$i.service
	echo -e "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/vncserver-$i.service

	# Change xfce4 keyboard setting for tab key
	sed -i 's/.*switch_window_key.*/\<property name\=\"\&lt\;Super\&gt\;Tab\" type\=\"empty\"\/\>/' /home/$i/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

	# Enable and start systemd service
	systemctl daemon-reload
	systemctl enable vncserver-$i.service
	systemctl start vncserver-$i.service

	x=$((x+1))
done
