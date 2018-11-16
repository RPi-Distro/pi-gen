#!/bin/bash -e

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

on_chroot << EOF
rm -f /etc/resolv.conf
touch /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolve.conf /etc/resolv.conf
sed -i -e 's/\/run\//\/var\/run\//' /etc/systemd/system/dhcpcd5.control
mv /etc/dhcpcd.conf /boot/
chown root:root /boot/dhcpcd.conf
ln -s /boot/dhcpcd.conf /etc/dhcpcd.conf
EOF

