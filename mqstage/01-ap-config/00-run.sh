#!/bin/bash -e
# Clone the latest version of the stem_club repository. In the interest of sorting out 

cd files/ && rm -r stem_club && git clone https://github.com/altmattr/stem_club.git
cd ..
sudo cp -a files/stem_club/shui "${ROOTFS_DIR}/home/pi/shui/"
sudo cp -a files/stem_club/picam_predict "${ROOTFS_DIR}/home/pi/picam_predict/"
install -m 644 files/shui/shui.service "${ROOTFS_DIR}/lib/systemd/system/"
# Copy preconfigured NetworkManager access point to directory
install -m 600 files/WiFiAP.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"
install -m 777 files/first-boot-rename "${ROOTFS_DIR}/etc/init.d/"
# Custom MOTD when logging in. Will provide IP address, shui status, system uptime, journalctl command
install -m 777 files/motd "${ROOTFS_DIR}/home/pi/"
# Using the code from raspi-config to enable NetworkManager and sense hat service. Also enabling first-boot program that refreshes SSID
on_chroot << EOF
update-rc.d first-boot-rename defaults
systemctl enable shui.service
systemctl -q stop dhcpcd 2> /dev/null
systemctl -q disable dhcpcd
systemctl -q enable NetworkManager
sudo dpkg --remove --force-depends raspi-config
sudo rm /etc/motd
cat /home/pi/motd | tee --append /home/pi/.bashrc
EOF
