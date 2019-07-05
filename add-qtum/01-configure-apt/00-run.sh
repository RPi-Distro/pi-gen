#!/bin/bash -e

install -m 644 files/qtum.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/qtum.gpg.key
on_chroot << EOF
apt-get update
EOF
