#!/bin/bash -e

# Specific autorotate of logs for GreenGrass
install -m 644 files/greengrass "${ROOTFS_DIR}/etc/logrotate.d/greengrass"
install -m 644 files/rsyslog "${ROOTFS_DIR}/etc/logrotate.d/rsyslog"

# Setup AutoStart / AutoLogin on Debian
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxsession/LXDE
install -m 644 files/autostart "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxsession/LXDE/autostart"

cat > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf" << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${FIRST_USER_NAME} --noclear %I \$TERM
EOF

sed "${ROOTFS_DIR}/etc/lightdm/lightdm.conf" -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=${FIRST_USER_NAME}/"

on_chroot << EOF
mkdir -p /opt/va
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.config/lxsession/LXDE/autostart
systemctl set-default graphical.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
EOF

# Mount a tmpfs in /opt/va for fast transfers between Lambdas
grep -qF '/opt/va' "${ROOTFS_DIR}/etc/fstab" || { 
	echo "tmpfs /opt/va tmpfs defaults,noatime,nosuid,size=256m 0 0" | tee -a "${ROOTFS_DIR}/etc/fstab" 
}
on_chroot << EOF
mkdir -p /opt/va
EOF

# Prepare the device for wwan0 connection
install -m 644 files/dhcpcd.conf "${ROOTFS_DIR}/etc/dhcpcd.conf"
install -m 755 files/qmi-network "${ROOTFS_DIR}/usr/bin/qmi-network"
install -m 600 files/expeto-wwan0.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/expeto-wwan0.nmconnection"
install -m 644 files/wwan0 "${ROOTFS_DIR}/etc/network/interfaces.d/wwan0"

# Make sure wlan0 is driven by dhcpcd.conf and not systemd
on_chroot << EOF
systemctl disable wpa_supplicant.service
EOF
