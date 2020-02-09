#!/bin/bash -e

install -m 644 files/greengrass "${ROOTFS_DIR}/etc/logrotate.d/greengrass"
install -m 644 files/rsyslog "${ROOTFS_DIR}/etc/logrotate.d/rsyslog"
grep -qxF '/opt/va' || { 
	echo "tmpfs /opt/va tmpfs defaults,noatime,nosuid,size=256m 0 0" | tee -a "${ROOTFS_DIR}/etc/fstab" 
}
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