#!/bin/bash -e

install -m 644 files/hostname "${ROOTFS_DIR}/etc/hostname"

ln -sf /dev/null "${ROOTFS_DIR}/etc/systemd/network/99-default.link"
