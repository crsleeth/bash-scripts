#!/bin/bash
if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 1
fi

echo "This script was tested on Ubuntu 14.04.5 LTS 64-bit"
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
wget https://bintray.com/tigervnc/stable/download_file?file_path=ubuntu-14.04LTS%2Famd64%2Ftigervncserver_1.8.0-3ubuntu1_amd64.deb
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

	# Backup default xstartup, create working xfce4 replacement
	cp /home/$i/.vnc/xstartup /home/$i/.vnc/xstartup.bak
	echo -e "#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\n" > /home/$i/.vnc/xstartup
	chown -R $i:$i /home/$i/.vnc
	chmod +x /home/$i/.vnc/xstartup

	# Create init.d service
	echo -e '#!/bin/bash
	PATH="$PATH:/usr/bin/"
	export USER='${i}'
	DISPLAY="1"
	DEPTH="16"
	GEOMETRY="1920x1080"
	OPTIONS="-depth ${DEPTH} -geometry ${GEOMETRY} :${DISPLAY} -localhost"
	. /lib/lsb/init-functions
	' > /etc/init.d/vncserver-$i

	echo -e 'case "$1" in
	start)
	log_action_begin_msg "Starting vncserver for user '${USER}' on localhost:${DISPLAY}"
	su ${USER} -c "/usr/bin/vncserver ${OPTIONS}"
	;;
	' >> /etc/init.d/vncserver-$i

	echo -e 'stop)
	log_action_begin_msg "Stopping vncserver for user '${USER}' on localhost:${DISPLAY}"
	su ${USER} -c "/usr/bin/vncserver -kill :${DISPLAY}"
	;;
	' >> /etc/init.d/vncserver-$i

	echo -e 'restart)
	$0 stop
	$0 start
	;;
	esac
	exit 0
	' >> /etc/init.d/vncserver-$i

	chmod +x /etc/init.d/vncserver-$i

	# Change xfce4 keyboard setting for tab key
	sed -i 's/.*switch_window_key.*/\<property name\=\"\&lt\;Super\&gt\;Tab\" type\=\"empty\"\/\>/' /home/$i/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

	# Start and enable init.d service
	service start vncserver
	update-rc.d vncserver defaults

	x=$((x+1))
done
