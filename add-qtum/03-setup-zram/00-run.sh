#!/bin/bash -e

install -m 755 files/zram "${ROOTFS_DIR}/etc/init.d/"

on_chroot << EOF
systemctl enable zram
EOF
