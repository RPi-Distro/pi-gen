#!/bin/bash -e

install -v -m 755 "files/mpc-cd.sh" "${ROOTFS_DIR}/usr/local/bin/mpc-cd.sh"
install -v -m 644 "files/cd-mount.service" "${ROOTFS_DIR}/etc/systemd/system/cd-mount.service”"
install -v -m 644 "files/99-cd.rules" "${ROOTFS_DIR}/etc/udev/rules.d/99-cd.rules"

on_chroot << EOF
	udevadm control --reload-rules
	systemctl daemon-reload
EOF