#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
systemctl enable regenerate_ssh_host_keys
EOF

if [ "${USE_QEMU}" = "1" ]; then
	log "enter QEMU mode"
	install -m 644 files/90-qemu.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
	on_chroot << EOF
systemctl disable resize2fs_once
EOF
	log "leaving QEMU mode"
else
	on_chroot << EOF
systemctl enable resize2fs_once
EOF
fi

if [ "${USE_SSH}" = "1" ]; then
	on_chroot << EOF
systemctl enable ssh
EOF

	if [[ -e files/authorized_keys ]]; then
		log "Copy authorized_keys in root ssh directory"
		install -d                            "${ROOTFS_DIR}/root/.ssh"
		install -m 644 files/authorized_keys 	"${ROOTFS_DIR}/root/.ssh/"
	fi
else
	on_chroot << EOF
systemctl disable ssh
EOF
fi

on_chroot << \EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r "$GRP"
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser ${RPI_USERNAME} $GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*
