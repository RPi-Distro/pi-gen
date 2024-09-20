#!/bin/bash

dpkg-reconfigure lightdm
sudo raspi-config nonint do_boot_behaviour B3
mkdir ${ROOTFS_DIR}/home/pi/Activities
cd ${ROOTFS_DIR}/home/pi/Activities
git clone https://github.com/44yu5h/gallery_activity.git
echo "###### Finished 01-run.sh #####"
