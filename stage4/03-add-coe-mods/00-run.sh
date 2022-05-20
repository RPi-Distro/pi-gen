#!/bin/bash -e

install -v -m 644 files/autostart "${ROOTFS_DIR}/etc/xdg/lxsession/LXDE-pi/autostart"

install -v -m 655 files/coe-client-ui "${ROOTFS_DIR}/opt/coe-client-ui"
install -v -m 644 files/coe-client.conf "${ROOTFS_DIR}/etc/coe-client.conf"

install -v -m 644 files/eGTouchL.ini "${ROOTFS_DIR}/etc/eGTouchL.ini"
install -v -m 655 files/eGTouchD "${ROOTFS_DIR}/opt/eGTouchD"
install -v -m 655 files/eCalib "${ROOTFS_DIR}/opt/eCalib"
install -v -m 777 files/eGTouchD.service "${ROOTFS_DIR}/etc/systemd/system/eGTouchD.service"
install -v -m 777 files/81-egalax-touchscreen.rules "${ROOTFS_DIR}/etc/udev/rules.d/81-egalax-touchscreen.rules"

install -v -m 644 files/freshclam.conf "${ROOTFS_DIR}/etc/clamav/freshclam.conf"
install -v -m 777 files/scan "${ROOTFS_DIR}/etc/cron.daily/scan"
install -v -m 644 files/crontab "${ROOTFS_DIR}/etc/crontab"

install -v -m 644 files/timesyncd.conf "${ROOTFS_DIR}/etc/systemd/timesyncd.conf"

install -v -m 777 files/firstboot.service "${ROOTFS_DIR}/lib/systemd/system/firstboot.service"
install -v -m 777 files/firstboot.sh "${ROOTFS_DIR}/boot/firstboot.sh"


on_chroot << EOF
#add bncsadmin user
adduser --gecos "" --disabled-password bncsadmin
usermod -a -G sudo bncsadmin
chpasswd <<< "bncsadmin:6G!S7NM>=U&t1%NA"

#remove default user from sudo and dont allow ssh - not sure why it has to be done here at the moment
deluser ${FIRST_USER_NAME} sudo

#don't allow bncs to login via ssh
echo -e 'DenyUsers\t${FIRST_USER_NAME}' >> /etc/ssh/sshd_config

#add vnc server
systemctl enable vncserver-x11-serviced.service

#disable logging
systemctl disable rsyslog
systemctl disable syslog.socket

#block wifi and bluetooth
rfkill block wifi
rfkill block bluetooth

#enable script that runs on first boot up only
systemctl enable firstboot.service
EOF
