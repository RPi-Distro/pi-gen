# Enable ssh.
touch ${ROOTFS_DIR}/boot/ssh

# Boot to graphical by default
on_chroot << EOF
	systemctl set-default graphical.target
	ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
	sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=pi/"
	ln -fs /usr/bin/i3 /etc/alternatives/x-session-manager
EOF

install -m 644 files/autologin.conf ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf

# Set up sudoers.d for user patch
rm -f ${ROOTFS_DIR}/etc/sudoers.d/010_pi-nopasswd
install -m 440 files/010_pi-nopasswd ${ROOTFS_DIR}/etc/sudoers.d/

echo pi - memlock 256000 >> ${ROOTFS_DIR}/etc/security/limits.conf
echo pi - rtprio 75 >> ${ROOTFS_DIR}/etc/security/limits.conf
