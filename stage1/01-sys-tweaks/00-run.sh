#!/bin/bash -e

install -d ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d
install -m 644 files/noclear.conf ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf
install -v -m 644 files/fstab ${ROOTFS_DIR}/etc/fstab

on_chroot << EOF
if ! id -u pi >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" pi
fi
echo "pi:raspberry" | chpasswd
echo "root:root" | chpasswd
EOF


