#!/bin/bash -e

install -m 755 files/firstboot.sh "${ROOTFS_DIR}/boot/firstboot.sh"
install -m 755 files/firstboot.service "${ROOTFS_DIR}/etc/systemd/system/firstboot.service"

on_chroot << EOF
systemctl enable firstboot.service
EOF
