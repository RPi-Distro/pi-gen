#!/bin/bash -e

# Please ensure you specify "OS_TYPE"="dride-plus" as an environment variable
# IF you wish to enable advanced feature for Dride/Rpi3
# Do not include if you are building for RPiZW


install -m 755 files/etc_initd_dride-ws ${ROOTFS_DIR}/etc/init.d/dride-ws
install -m 755 files/etc_initd_dride-core ${ROOTFS_DIR}/etc/init.d/dride-core
install -m 644 files/lib_udev_hwclock-set ${ROOTFS_DIR}/lib/udev/hwclock-set

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

echo "========== Create DRIDE path ==========="
# create the video/content destination
sudo mkdir -p /dride/clip /dride/thumb /dride/tmp_clip

cd /home

# Install dependencies
echo "========== Update Aptitude ==========="
# sudo apt-get update -y
# sudo apt-get upgrade

if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Installing build-essential ============"
	sudo apt-get install build-essential -y

	echo "========== Installing libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libjasper-dev python2.7-dev ============"
	sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libjasper-dev python2.7-dev -y
fi

echo "========== Installing gpac ============"
# provides MP4Box
sudo apt-get install gpac -y

echo "========== Installing htop ============"
sudo apt-get install htop -y


echo "========== Setup libav  ============"
# provides avconv
sudo apt-get install libav-tools -y


echo "========== Installing Node ============"
wget -O - https://raw.githubusercontent.com/sdesalas/node-pi-zero/master/install-node-v8.9.0.sh | bash


echo "========== Installing pip ============"
sudo apt-get install python-pip -y


if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Installing Numpy ============"
	sudo pip install numpy
fi


echo "========== Install picamera  ============"
sudo apt-get install python3-picamera


# enable camera on raspi-config and allocate more ram to the GPU
echo "" >> /boot/config.txt
echo "#enable piCaera" >> /boot/config.txt
echo "start_x=1" >> /boot/config.txt
echo "gpu_mem=128" >> /boot/config.txt
echo "dtparam=spi=on" >> /boot/config.txt


if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Install mpg123  ============"
	sudo apt-get install mpg123 -y
fi


echo "========== Install pyserial  ============"
sudo pip install pyserial


#startup script's
# sudo wget https://dride.io/code/startup/dride-ws


# if [ ${OS_TYPE} == "dride-plus" ]; then
# 	sudo wget https://dride.io/code/startup/dride-core
# else
# 	sudo wget https://dride.io/code/startup/dride-core
# fi;


# express on startup
# sudo cp dride-ws /etc/init.d/dride-ws
# sudo chmod +x /etc/init.d/dride-ws
sudo update-rc.d dride-ws defaults
# sudo rm dride-ws


# dride-core on startup
# if [ ${OS_TYPE} == "dride-plus" ]; then
# 	sudo cp dride-core /etc/init.d/dride-core
# else
# 	sudo cp dride-core /etc/init.d/dride-core
# fi;


# sudo chmod +x /etc/init.d/dride-core
sudo update-rc.d dride-core defaults
# sudo rm dride-core


if [ ${OS_TYPE} == "dride-plus" ]; then
	## GPS  https://www.raspberrypi.org/forums/viewtopic.php?p=947968#p947968
	echo "========== Install GPS  ============"
	sudo apt-get install gpsd gpsd-clients cmake subversion build-essential espeak freeglut3-dev imagemagick libdbus-1-dev libdbus-glib-1-dev libdevil-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libgarmin-dev libglc-dev libgps-dev libgtk2.0-dev libimlib2-dev libpq-dev libqt4-dev libqtwebkit-dev librsvg2-bin libsdl-image1.2-dev libspeechd-dev libxml2-dev ttf-liberation -y

	echo "" >> /boot/config.txt
	echo "enable_uart=1" >> /boot/config.txt

	# this will be done after initial boot
	# echo "dwc_otg.lpm_enable=0  console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4  elevator=deadline fsck.repair=yes spidev.bufsiz=32768 rootwait" > /boot/cmdline.txt

	# 3)Run
	sudo systemctl stop serial-getty@ttyS0.service
	sudo systemctl disable serial-getty@ttyS0.service
	sudo systemctl stop gpsd.socket
	sudo systemctl disable gpsd.socket

	# reboot

	# 5) Execute the daemon reset
	#sudo killall gpsd
	#sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock
fi


if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Downloading and installing OpenCV ============"
	cd /
	# git clone https://github.com/Itseez/opencv.git --depth 1
	wget -c -O "opencv-3.1.0.zip" "https://github.com/Itseez/opencv/archive/3.1.0.zip"
	sudo apt-get install unzip
	unzip -q -n "opencv-3.1.0.zip"

	cd opencv-3.1.0
	echo "======== Building OpenCV ============"
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

	# TODO: Add a test if openCV was installed correctly
fi


echo "========== Setup sound to I2S  ============"
sudo curl -sS https://dride.io/code/i2samp.sh  | bash


echo "========== Setup mic  ============"
# https://learn.adafruit.com/adafruit-i2s-mems-microphone-breakout/raspberry-pi-wiring-and-test


echo "========== Setup RTC  ============"
# https://learn.adafruit.com/adding-a-real-time-clock-to-raspberry-pi/set-rtc-time
sudo apt-get install python-smbus i2c-tools
# TODO: turn on ISC on raspi-config...


# add to sudo nano /boot/config.txt
echo "dtoverlay=i2c-rtc,ds3231,dwc2" >> /boot/config.txt
echo "dtparam=i2c_arm=on" >> /boot/config.txt


# Remove hw-clock
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove


# copy new file to
# sudo wget https://dride.io/code/hwclock-set
# sudo cp hwclock-set /lib/udev/hwclock-set
# sudo rm hwclock-set
# we will sync the current date form the app using BLE
# looks at /daemon/bluetooth/updateDate.js


echo "========== Setup Accelerometer  ============"
# http://www.stuffaboutcode.com/2014/06/raspberry-pi-adxl345-accelerometer.html
# enable i2c 0
echo "# Accelerometer" >> /boot/config.txt
echo "dtparam=i2c_vc=on" >> /boot/config.txt


echo "========== Install Dride-core [Cardigan]  ============"
cd /home
# https://s3.amazonaws.com/dride/releases/cardigan/latest.zip
sudo mkdir Cardigan && cd Cardigan
sudo wget -c -O "cardigan.zip" "https://s3.amazonaws.com/dride/releases/cardigan/latest.zip"
sudo unzip "cardigan.zip"
sudo rm -R cardigan.zip


# make the video dir writable
sudo chmod 777 -R /home/Cardigan/modules/video/
sudo chmod 777 -R /home/Cardigan/modules/settings/
# make gps position writable
sudo chmod +x /home/Cardigan/daemons/gps/position


# make the firmware dir writable
sudo chmod 777 -R /home/Cardigan/firmware/


# run npm install on video module
cd /home/Cardigan/modules/video
sudo npm i --production
# set proper soft links to use /dride path
sudo rm -rf tmp_clip/
sudo ln -s /dride/tmp_clip/ tmp_clip
sudo rm -rf thumb/
sudo ln -s /dride/thumb/ thumb
sudo rm -rf clip/
sudo ln -s /dride/clip/ clip


# run npm install on dride-ws
cd /home/Cardigan/dride-ws
sudo npm i --production


# setup clear cron job
crontab -l > cleanerJob
echo "* * * * * node /home/Cardigan/modules/video/helpers/cleaner.js" >> cleanerJob
# install new cron file
crontab cleanerJob
rm cleanerJob


echo "========== Install Indicators  ============"
echo "# Needed for SPI LED" >> /boot/config.txt
echo "core_freq=250" >> /boot/config.txt
sudo apt-get install scons
cd /home/Cardigan/modules/indicators
sudo scons
sudo apt-get install python-dev swig -y
cd /home/Cardigan/modules/indicators/python
sudo python setup.py install


echo "========== Setup bluetooth  ============"
sudo apt-get install bluetooth bluez libbluetooth-dev libudev-dev -y
# run npm install on Bluetooth daemon
cd /home/Cardigan/daemons/bluetooth
sudo npm i --production


echo ""
echo '============================='
echo '*****************************'
echo '========= Finished =========='
echo '*****************************'
echo '============================='
echo ""

EOF
