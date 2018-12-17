#!/bin/bash -e

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

on_chroot << EOF
rm -f /etc/resolv.conf
touch /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolve.conf /etc/resolv.conf
sed -i -e 's/\/run\//\/var\/run\//' /etc/systemd/system/dhcpcd5.service
mv /etc/dhcpcd.conf /boot/
chown root:root /boot/dhcpcd.conf
ln -s /boot/dhcpcd.conf /etc/dhcpcd.conf
EOF

if [ -v WPA_COUNTRY ]
then
	echo "country=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

if [ -v WPA_ESSID -a -v WPA_PASSWORD ]
then
on_chroot <<EOF
wpa_passphrase ${WPA_ESSID} ${WPA_PASSWORD} >> "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
fi
