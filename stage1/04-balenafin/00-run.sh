#!/bin/bash -e

install -m 644 files/balenafin.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/bintray-public.key.asc
on_chroot << EOF
apt-get update
EOF
