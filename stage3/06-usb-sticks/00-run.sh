#!/bin/bash -e

install -v -m 755 'files/mpc-usb.sh' "${ROOTFS_DIR}/usr/local/bin/mpc-usb.sh"
install -v -m 755 'files/usb-mount.sh' "${ROOTFS_DIR}/usr/local/bin/usb-mount.sh"

install -v -m 644 'files/usb-mount@.service' "${ROOTFS_DIR}/etc/systemd/system/usb-mount@.service"
install -v -m 644 'files/99-usb.rules' "${ROOTFS_DIR}/etc/udev/rules.d/99-usb.rules"
install -v -o 1000 -g 29 -m 644 'files/.mpdignore' "${ROOTFS_DIR}/media/USB/.mpdignore"

on_chroot << EOF
#	udevadm control --reload-rules
#	systemctl daemon-reload
EOF