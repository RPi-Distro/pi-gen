#!/bin/bash -e

install -m 644 files/docker.list "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
install -m 644 files/kubernetes.list "${ROOTFS_DIR}/etc/apt/sources.list.d/kubernetes.list"

on_chroot apt-key add - < files/docker.gpg.key
on_chroot apt-key add - < files/kubernetes.gpg.key
on_chroot << EOF
apt-get update
EOF