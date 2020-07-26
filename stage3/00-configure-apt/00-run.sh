#!/bin/bash -e

install -m 644 files/blokas.list ${ROOTFS_DIR}/etc/apt/sources.list.d/

on_chroot apt-key add - < files/blokas.gpg.key
on_chroot << EOF
apt-get update
EOF
