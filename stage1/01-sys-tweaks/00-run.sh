#!/bin/bash -e

install -d ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d
install -m 644 files/noclear.conf ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf
install -m 744 files/policy-rc.d ${ROOTFS_DIR}/usr/sbin/policy-rc.d
install -v -m 644 files/fstab ${ROOTFS_DIR}/etc/fstab

on_chroot sh -e - <<EOF
if ! id -u ${USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${USER_NAME}
fi
echo "${USER_NAME}:${PASS_WORD}" | chpasswd
echo "root:root" | chpasswd
EOF


