#!/bin/bash -e

mkdir "${ROOTFS_DIR}/etc/docker"
install -m 644 files/daemon.json "${ROOTFS_DIR}/etc/docker/daemon.json"

on_chroot << EOF
usermod -aG docker $FIRST_USER_NAME
EOF
