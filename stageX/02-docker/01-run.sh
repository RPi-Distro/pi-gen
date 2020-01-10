#!/bin/bash -e

install -m 755 files/install-docker.sh "${ROOTFS_DIR}/tmp/"

on_chroot << EOF
/tmp/install-docker.sh
usermod -aG docker pi
EOF
