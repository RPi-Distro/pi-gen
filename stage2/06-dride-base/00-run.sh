#!/bin/bash -e

# Please ensure you specify "OS_TYPE"="dride-plus" as an environment variable
# IF you wish to enable advanced feature for Dride/Rpi3
# Do not include if you are building for RPiZW


install -m 755 files/etc_initd_dride-core ${ROOTFS_DIR}/etc/init.d/dride-core
install -m 644 files/lib_udev_hwclock-set ${ROOTFS_DIR}/lib/udev/hwclock-set

install -m 644 files/systemctl/ble.service ${ROOTFS_DIR}/lib/systemd/system/ble.service
install -m 644 files/systemctl/record.service ${ROOTFS_DIR}/lib/systemd/system/record.service
install -m 644 files/systemctl/ws.service ${ROOTFS_DIR}/lib/systemd/system/ws.service
install -m 644 files/systemctl/live.service ${ROOTFS_DIR}/lib/systemd/system/live.service
install -m 644 files/systemctl/led.service ${ROOTFS_DIR}/lib/systemd/system/led.service
install -m 644 files/systemctl/rtc.service ${ROOTFS_DIR}/lib/systemd/system/rtc.service

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
sudo apt-get update -y
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



# express on startup
sudo systemctl enable ws

# dride-core on startup
sudo update-rc.d dride-core defaults
sudo systemctl enable record
sudo systemctl enable ble
sudo systemctl enable led
sudo systemctl enable rtc

if [ ${OS_TYPE} == "dride-plus" ]; then
	## GPS  https://www.raspberrypi.org/forums/viewtopic.php?p=947968#p947968
	echo "========== Install GPS  ============"

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

if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Setup sound to I2S  ============"
	sudo curl -sS https://dride.io/code/i2samp.sh  | bash
fi

if [ ${OS_TYPE} == "dride-plus" ]; then
	echo "========== Setup mic  ============"
	# https://learn.adafruit.com/adafruit-i2s-mems-microphone-breakout/raspberry-pi-wiring-and-test
fi

echo "========== Setup RTC  ============"
# https://learn.adafruit.com/adding-a-real-time-clock-to-raspberry-pi/set-rtc-time
sudo apt-get install python-smbus i2c-tools -y

# add to /boot/config.txt
echo "dtoverlay=i2c-rtc,ds1307" >> /boot/config.txt
echo "dtparam=i2c_arm=on" >> /boot/config.txt

# add to /etc/modules
echo "i2c-dev" >> /etc/modules
echo "rtc-ds1307" >> /etc/modules


# Remove hw-clock
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove

# we will sync the current date form the app using BLE
# looks at /daemon/bluetooth/updateDate.js


echo "========== Setup Accelerometer  ============"
# http://www.stuffaboutcode.com/2014/06/raspberry-pi-adxl345-accelerometer.html
# enable i2c 0
echo "# Accelerometer" >> /boot/config.txt
echo "dtparam=i2c_vc=on" >> /boot/config.txt


echo "========== Install Dride-core   ============"
cd /home
# https://s3.amazonaws.com/dride/releases/dride/latest.zip
sudo wget -c -O "core.zip" "https://s3.amazonaws.com/dride/releases/dride/latest.zip"
sudo unzip "core.zip"
sudo rm -R core.zip
cd core

echo "========== Create video path ==========="
# create the video/content destination
sudo mkdir -p /dride/clip /dride/thumb /dride/tmp_clip


sudo chmod 777 -R /dride/
sudo chmod 777 -R /home/core/modules/settings/
# make gps position writable
sudo chmod +x /home/core/daemons/gps/position


# make the firmware dir writable
sudo chmod 777 -R /home/core/firmware/

# make the state dir writable
sudo chmod 777 -R /home/core/state/


# run npm install on dride-ws
cd /home/core/dride-ws
sudo npm i --production

# run npm install on modules/video
cd /home/core/modules/video
sudo npm i --production

echo "========== Add CronJobs  ============"

# setup clear cron job
sudo crontab -l > cronJobs

# setup cleaner cron job
sudo echo "* * * * * sudo node /home/core/modules/video/helpers/cleaner.js" >> cronJobs

# setup ensureAllClipsAreDecoded cron job
sudo echo "* * * * * sudo node /home/core/modules/video/helpers/ensureAllClipsAreDecoded.js" >> cronJobs

sudo crontab cronJobs
sudo rm cronJobs



echo "========== Install LED  ============"
sudo apt-get install scons -y
echo "# Needed for SPI LED" >> /boot/config.txt
echo "core_freq=250" >> /boot/config.txt

cd /home/core/modules/led
sudo npm i
sudo chmod 0777 bin/main


echo "======== raspivid =========="
cd /home/core
sudo git clone https://github.com/dride/userland
cd userland
./buildme


echo "========== Setup bluetooth  ============"
sudo apt-get install bluetooth bluez libbluetooth-dev libudev-dev -y
# run npm install on Bluetooth daemon
cd /home/core/daemons/bluetooth
sudo npm i --production


echo ""
echo '============================='
echo '*****************************'
echo '========= Finished =========='
echo '*****************************'
echo '============================='
echo ""

EOF
