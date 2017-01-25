#!/bin/bash -e

install -m 644 files/regenerate_ssh_host_keys.service	${ROOTFS_DIR}/lib/systemd/system/
install -m 755 files/apply_noobs_os_config		${ROOTFS_DIR}/etc/init.d/
install -m 755 files/resize2fs_once			${ROOTFS_DIR}/etc/init.d/

install -d						${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d
install -m 644 files/ttyoutput.conf			${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/

install -m 644 files/50raspi				${ROOTFS_DIR}/etc/apt/apt.conf.d/


on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
systemctl enable ssh
systemctl enable regenerate_ssh_host_keys
systemctl enable apply_noobs_os_config
systemctl enable resize2fs_once
EOF

on_chroot << \EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r $GRP
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser pi $GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

on_chroot << EOF
usermod --pass='*' root
EOF

rm -f ${ROOTFS_DIR}/etc/ssh/ssh_host_*_key*

on_chroot << EOF


#-------------------------------------------------------
# Script to check if all is good before install script runs
#-------------------------------------------------------

echo "====== Dride install script ======"
echo ""
echo ""
echo ""
echo "██████╗ ██████╗ ██╗██████╗ ███████╗"
echo "██╔══██╗██╔══██╗██║██╔══██╗██╔════╝"
echo "██║  ██║██████╔╝██║██║  ██║█████╗  "
echo "██║  ██║██╔══██╗██║██║  ██║██╔══╝  "
echo "██████╔╝██║  ██║██║██████╔╝███████╗"
echo "╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝"
echo ""
echo ""
echo "This will install all the necessary dependences and software for dride."
echo "======================================================="
echo ""
echo ""



echo ""
echo ""
echo "==============================="
echo "*******************************"
echo " *** STARTING INSTALLATION ***"
echo "  ** this may take a while **"
echo "   *************************"
echo "   ========================="
echo ""
echo ""



cd /home

# Install dependencies
echo "========== Update Aptitude ==========="
# sudo apt-get update -y
# sudo apt-get upgrade

echo "========== Installing build-essential ============"
sudo apt-get install build-essential -y

echo "========== Installing git ============"
sudo apt-get install git -y


echo "========== Installing libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libjasper-dev python2.7-dev ============"
sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libjasper-dev python2.7-dev -y


# Install Node
echo "========== Installing Node ============"
sudo wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb

sudo rm /home/node_latest_armhf.deb


# TODO: Add a test if openCV was installed correctly

echo "========== Install Dride-core [Cardigan]  ============"
cd /home
# https://github.com/dride/Cardigan/archive/0.2.zip
wget -c -O "cardigan-0.2.zip" "https://github.com/dride/Cardigan/releases/download/0.2/Cardigan.zip"
unzip -q -n "cardigan-0.2.zip"

sudo rm cardigan-0.2.zip

sudo rm -R __MACOSX


# make the video dir writable
sudo chmod 777 -R /home/Cardigan/modules/video/

# clone dride-ws 
cd /home/Cardigan/dride-ws

sudo npm i

cd /home


echo "========== Installing pip ============"
sudo wget https://bootstrap.pypa.io/get-pip.py
sudo chmod +x get-pip.py
sudo python get-pip.py

echo "========== Installing Numpy ============"
sudo pip install numpy

sudo rm get-pip.py

echo "========== Downloading and installing OpenCV ============"
cd /
# git clone https://github.com/Itseez/opencv.git --depth 1
wget -c -O "opencv-3.1.0.zip" "https://github.com/Itseez/opencv/archive/3.1.0.zip"
sudo apt-get install unzip
unzip -q -n "opencv-3.1.0.zip"

cd opencv-3.1.0
echo "==>>>====== Building OpenCV ============"
cd /home/opencv-3.1.0
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_EXAMPLES=OFF -D BUILD_opencv_apps=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local ..
echo "==>>>====== This might take a long time.. ============"
make -j1

sudo make install
sudo ldconfig

# remove the installation file
cd /
sudo rm opencv-3.1.0.zip





echo "========== Install picamera  ============"
sudo pip install "picamera[array]"
# enable camera on raspi-config
echo "" >> /boot/config.txt
echo "#enable piCaera" >> /boot/config.txt
echo "start_x=1" >> /boot/config.txt


echo "========== Install omxplayer  ============"
sudo apt-get install omxplayer -y


# Install WIFi
sudo apt-get install hostapd isc-dhcp-server -y
sudo apt-get install iptables-persistent -y

cd /home 
# get the dhcpd config file
sudo wget https://dride.io/code/dhcpd.conf

sudo cp dhcpd.conf /etc/dhcp/dhcpd.conf
sudo rm dhcpd.conf


sudo bash -c 'echo "INTERFACES=\"wlan0\""> /etc/default/isc-dhcp-server'

sudo ifdown wlan0


sudo wget https://dride.io/code/interfaces

sudo cp interfaces /etc/network/interfaces
sudo rm interfaces


sudo ifconfig wlan0 192.168.42.1


sudo wget https://dride.io/code/hostapd.conf

sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo rm hostapd.conf

sudo bash -c 'echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""> /etc/default/hostapd'

sudo wget https://dride.io/code/hostapd

sudo cp hostapd /etc/init.d/hostapd
sudo rm hostapd


sudo bash -c 'echo "net.ipv4.ip_forward=1"> /etc/sysctl.conf'
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT


sudo sh -c "iptables-save > /etc/iptables/rules.v4"

sudo mv /usr/share/dbus-1/system-services/fi.epitest.hostap.WPASupplicant.service ~/


sudo service hostapd start 
sudo service isc-dhcp-server start
sudo update-rc.d hostapd enable 
sudo update-rc.d isc-dhcp-server enable



sudo wget https://dride.io/code/startup/dride-ws
sudo wget https://dride.io/code/startup/dride-core

#startup script's

# express on startup
sudo cp dride-ws /etc/init.d/dride-ws
sudo chmod +x /etc/init.d/dride-ws
sudo update-rc.d dride-ws defaults


sudo rm dride-ws

# dride-core on startup
sudo cp dride-core /etc/init.d/dride-core
sudo chmod +x /etc/init.d/dride-core
sudo update-rc.d dride-core defaults
sudo rm dride-core



















echo ""
echo '============================='
echo '*****************************'
echo '========= Finished =========='
echo '*****************************'
echo '============================='
echo ""


EOF