#!/bin/bash -e

curl -fsSL https://deb.nodesource.com/setup_lts.x -O files/setup_lts.x
install -m 755 files/setup_lts.x	"${ROOTFS_DIR}/tmp/"

on_chroot << EOF
bash /tmp/setup_lts.x
apt-get install -y nodejs
EOF
