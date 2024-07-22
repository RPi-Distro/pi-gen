#!/bin/bash -e

install -v -m 644 file/upmpdcli.list "${ROOTFS_DIR}/etc/apt/sources.list.d/upmpdcli.list"

on_chroot << EOF
	apt-update
EOF
