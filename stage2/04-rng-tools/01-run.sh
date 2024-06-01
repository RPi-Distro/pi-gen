#!/bin/bash -e

install -m 644 files/rng-tools.service	"${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl -f enable rng-tools
EOF
