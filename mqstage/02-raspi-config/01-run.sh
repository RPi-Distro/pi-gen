#!/bin/bash -e
install -m 777 files/autologin.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/"
on_chroot << EOF
systemctl --quiet set-default multi-user.target
EOF