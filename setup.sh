#!/bin/bash
# This script is used to setup rspiducky by theresalu on github
# This script will only work on the Raspberry Pi Zero

if [ $EUID -ne 0 ]; then
	echo "You must use sudo to run this script:"
	echo "sudo $0 $@"
	exit
fi

apt-get update

## dwc2 drivers
sed -i -e "\$adtoverlay=dwc2" /boot/config.txt


##Install git and download rspiducky
apt-get install -y git
git clone https://github.com/dee-oh-double-gee/rspiducky /home/pi

##Compile hid-gadget-test
gcc hid-gadget-test.c -o hid-gadget-test

##Compile usleep 
make usleep

##Make all nessisary files executeable
cd /home/pi
chmod 755 hid-gadget-test.c duckpi.sh usleep.c g_hid.ko

cp g_hid.ko /lib/modules/4.4.0+/kernel/drivers/usb/gadget/legacy

cat <<'EOF'>>/etc/modules
dwc2
g_hid
EOF


##Make it so that you can put the payload.dd in the /boot directory
sed -i '/exit/d' /etc/rc.local

cat <<'EOF'>>/etc/rc.local
sleep 3
cat /boot/payload.dd > /home/pi/payload.dd
sleep 1
tr -d '\r' < /home/pi/payload.dd > /home/pi/payload2.dd
sleep 1
/home/pi/duckpi.sh /home/pi/payload2.dd
exit 0
EOF


cat <<'EOF'>>/boot/payload.dd
GUI r
DELAY 50
STRING www.youtube.com/watch?v=dQw4w9WgXcQ
ENTER
EOF
