#!/bin/bash -e

install -v -m 644 files/lesbonscomptes.gpg "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/lesbonscomptes.gpg"
install -v -m 644 files/upmpdcli.list "${ROOTFS_DIR}/etc/apt/sources.list.d/upmpdcli.list"

on_chroot << EOF
	apt-get update
EOF
