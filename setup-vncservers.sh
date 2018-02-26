#!/bin/bash
if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit 1
fi

echo "This script was tested on Ubuntu 16.04.4 LTS 64-bit"
echo "Before running this script please create any users in System Settings"
echo "Also, login to them AT LEAST ONCE"
echo "This script installs packages: tightvncserver, xfce4"
read -p "Have you done the above steps? Continue? (Y/n): " -n 1
if [[ $REPLY =~ ^[Nn]$ ]]
then
	exit 1
fi

echo "Updating apt"
apt update -y
echo "Installing packages"
apt install -y tightvncserver xfce4

x=1

read -p "Which user accounts do you want to setup vncserver for? Use space as a delimiter: " -a users
for i in "${users[@]}"
do
	echo "OK, setting up user $i vncserver"

	runuser -l $i -c "/usr/bin/vncserver"
	runuser -l $i -c "/usr/bin/vncserver -kill :1"
	runuser -l $i -c "/usr/bin/vncserver -kill :$x"

	cp /home/$i/.vnc/xstartup /home/$i/.vnc/xstartup.bak
	echo -e "#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\n" > /home/$i/.vnc/xstartup
	chown -R $i:$i /home/$i/.vnc
	chmod +x /home/$i/.vnc/xstartup

	echo -e "[Unit]\nDescription=TightVNC server for $i\nAfter=syslog.target network.target\n" > /etc/systemd/system/vncserver-$i.service
	echo -e "[Service]\nType=forking\nUser=$i\nPAMName=login\nPIDFile=/home/$i/.vnc/%H:$x.pid\nExecStartPre=-/usr/bin/vncserver -kill :$x > /dev/null 2>&1\nExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :$x\nExecStop=/usr/bin/vncserver -kill :$x\n" >> /etc/systemd/system/vncserver-$i.service
	echo -e "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/vncserver-$i.service

	systemctl daemon-reload
	systemctl enable vncserver-$i.service
	systemctl start vncserver-$i.service

	x=$((x+1))
done
