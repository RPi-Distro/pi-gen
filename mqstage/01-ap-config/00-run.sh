#!/bin/bash -e
# Clone the latest version of the stem_club repository
cd files/ && rm -r stem_club && git clone https://github.com/altmattr/stem_club.git
cd ..
sudo cp -a files/stem_club "${ROOTFS_DIR}/home/pi/stem_club/"
# Install all the services included in the stem_club repository. Only the interface is enabled from boot. 
install -m 644 "${ROOTFS_DIR}/home/pi/stem_club/services/interface.service" "${ROOTFS_DIR}/lib/systemd/system/"
install -m 644 "${ROOTFS_DIR}/home/pi/stem_club/services/prediction.service" "${ROOTFS_DIR}/lib/systemd/system/"
install -m 644 "${ROOTFS_DIR}/home/pi/stem_club/services/sensors.service" "${ROOTFS_DIR}/lib/systemd/system/"
# Copy preconfigured NetworkManager access point config to directory
install -m 600 files/*.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"
# Load the first-boot service to randomise the SSID
# Disabling this as it doesn't seem necessary. Not gonna remove entirely just in case. Make sure to reenable rcd update if enabling.
#install -m 777 files/first-boot-rename "${ROOTFS_DIR}/etc/init.d/"
# Load the service to rename the SSID on boot
install -m 777 files/rename-on-boot "${ROOTFS_DIR}/etc/init.d/"
# Custom MOTD when logging in. Will provide IP address, shui status, system uptime, journalctl command
install -m 777 files/motd "${ROOTFS_DIR}/home/pi/"
# Using the code from raspi-config to enable NetworkManager, also sense hat, first-boot program, custom MOTD
#sudo update-rc.d first-boot-rename defaults
# sudo chmod +x /home/pi/shui/*.py
# sudo chmod +x /home/pi/shui/*.sh
# sudo chmod +x /home/pi/picam_predict/*.py
on_chroot << EOF
update-rc.d rename-on-boot defaults
systemctl enable interface.service
systemctl -q stop dhcpcd 2> /dev/null
systemctl -q disable dhcpcd
systemctl -q enable NetworkManager
cat /home/pi/motd | tee --append /home/pi/.bashrc
rm /home/pi/motd

sudo chmod -R 777 /home/pi/
EOF
