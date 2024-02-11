#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

if [ "${FILE_SYSTEM_TYPE}" == "ext4" ]; then
	echo "ROOTDEV  /               ext4    defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
elif [ "${FILE_SYSTEM_TYPE}" == "btrfs" ]; then
	echo "ROOTDEV  /               btrfs   subvol=@,defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
	echo "ROOTDEV  /home           btrfs   subvol=@home,defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
	echo "ROOTDEV  /var/lib        btrfs   subvol=@var-lib,defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
else
	echo "Unsupported root file system type '${FILE_SYSTEM_TYPE}'. Only ext4 and btrfs are supported."
	exit 1
fi

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


