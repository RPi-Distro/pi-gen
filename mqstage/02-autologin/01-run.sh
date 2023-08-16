#!/bin/bash -e
install -m 777 files/autologin.sh "${ROOTFS_DIR}/home/pi/"
on_chroot << EOF
sudo chmod +x /home/pi/autologin.sh
cd /home/pi
sudo ./autologin.sh
rm -rf /home/pi/autologin.sh
EOF