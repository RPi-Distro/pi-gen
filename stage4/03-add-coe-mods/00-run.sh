#!/bin/bash -e

install -v -m 644 files/autologin "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
install -v -m 644 files/autostart "${ROOTFS_DIR}/etc/xdg/lxsession/LXDE-pi/autostart"

install -v -m 655 files/thinclient-ui "${ROOTFS_DIR}/opt/thinclient-ui"
install -v -m 644 files/thinclient-client.conf "${ROOTFS_DIR}/etc/thinclient-client.conf"

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
install -v -m 777 files/firstboot.sh "${ROOTFS_DIR}/opt/firstboot.sh"

install -v -m 744 files/65-srvrkeys-none "${ROOTFS_DIR}/etc/X11/Xsession.d/65-srvrkeys-none"

install -v -m 644 files/thinclient-client.conf "${ROOTFS_DIR}/boot/thinclient-client.conf"
install -v -m 644 files/net.cfg "${ROOTFS_DIR}/boot/net.cfg"


on_chroot << EOF
# create hostname file
echo thinclient > /boot/hostname

#add admin user
if adduser --gecos "" --disabled-password tcadmin; then
 usermod -a -G sudo tcadmin
 chpasswd <<< "tcadmin:6G!S7NM>=U&t1%NA"
fi

#remove default user from sudo not sure why it has to be done here at the moment
if deluser ${FIRST_USER_NAME} sudo; then
 echo "removed tcuser from sudo"
fi

#don't allow tcuser to login via ssh
echo -e 'DenyUsers\t${FIRST_USER_NAME}' >> /etc/ssh/sshd_config

#disable logging
systemctl disable rsyslog
systemctl disable syslog.socket

#block wifi and bluetooth
rfkill block wifi
rfkill block bluetooth

#enable script that runs on first boot up only
systemctl enable firstboot.service
EOF
