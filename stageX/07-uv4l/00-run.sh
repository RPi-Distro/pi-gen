#!/bin/bash -e

install -m 644 files/uv4l.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/lpkey.asc
on_chroot << EOF
apt update
EOF
