#!/bin/bash -e

install -m 644 files/balenafin.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/%%RELEASE%%/${RELEASE}/" "${ROOTFS_DIR}/etc/apt/sources.list.d/balenafin.list"

on_chroot apt-key add - < files/cloudsmith-public.key.asc
on_chroot << EOF
apt-get update
EOF
