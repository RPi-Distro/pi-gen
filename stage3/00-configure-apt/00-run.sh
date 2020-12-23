#!/bin/bash -e

install -m 644 files/jambox-project.list ${ROOTFS_DIR}/etc/apt/sources.list.d/
install -m 644 files/blokas.list ${ROOTFS_DIR}/etc/apt/sources.list.d/

on_chroot apt-key add - < files/repo.jambox-project.com.gpg
on_chroot apt-key add - < files/blokas.gpg.key
on_chroot << EOF
apt-get update
EOF
