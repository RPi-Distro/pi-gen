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
chpasswd <<< "bncsadmin:${BNCS_ADMIN_PASS}"
systemctl enable vncserver-x11-serviced.service
systemctl disable rsyslog
systemctl disable syslog.socket
rfkill block wifi
rfkill block bluetooth
systemctl enable firstboot.service
EOF
