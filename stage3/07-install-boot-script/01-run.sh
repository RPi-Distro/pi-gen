
# install urlrelay files for browser to locate access to UI
cp files/urlrelay.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/urlrelay.sh

mkdir -p ${ROOTFS_DIR}/etc/urlrelay
cp files/urlrelay.conf ${ROOTFS_DIR}/etc/urlrelay/

# install urlrelay service file
install -m 644 files/urlrelay.service ${ROOTFS_DIR}/lib/systemd/system

# set to autologin to graphical environment
cat > ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $FIRST_USER_NAME --noclear %I \$TERM
EOF

sed ${ROOTFS_DIR}/etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=$FIRST_USER_NAME/"
# disable raspi-config at boot
rm -f ${ROOTFS_DIR}/etc/profile.d/raspi-config.sh
#rm -r ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf

# Copy payload files to boot partition and edit
mkdir -p ${ROOTFS_DIR}/boot/payload/etc/urlrelay
cp files/urlrelay.conf ${ROOTFS_DIR}/boot/payload/etc/urlrelay/
cp ${ROOTFS_DIR}/etc/jackdrc.conf ${ROOTFS_DIR}/boot/payload/etc/
cp ${ROOTFS_DIR}/etc/timezone ${ROOTFS_DIR}/boot/payload/etc/

# Copy pi-boot-script files
cp files/unattended ${ROOTFS_DIR}/boot/
# cp files/one-time-script.conf ${ROOTFS_DIR}/boot/

sed -i 's|init=.*$|init=/bin/bash -c "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; source /boot/unattended"|' ${ROOTFS_DIR}/boot/cmdline.txt

on_chroot << EOF
	systemctl enable urlrelay
	systemctl set-default graphical.target
	ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
EOF


