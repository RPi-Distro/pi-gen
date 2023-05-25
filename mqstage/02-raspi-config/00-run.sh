#!/bin/bash -e

sudo apt install -y debhelper
git clone https://github.com/mqjasper/raspi-config.git
sudo dpgksource --before-build raspi-config/ && cd raspi-config && sudo dpkg-buildpackage --force-sign 

install -m 777 raspi*.deb "${ROOTFS_DIR}/home/pi/"

on_chroot << EOF
sudo dpkg -i /home/pi/*.deb
EOF