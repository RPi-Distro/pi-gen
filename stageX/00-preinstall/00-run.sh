#!/bin/bash -e

install -m 644 files/nodesource.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/nodesource.gpg.key
on_chroot << EOF
apt-get update
apt-get upgrade -yqq
EOF
