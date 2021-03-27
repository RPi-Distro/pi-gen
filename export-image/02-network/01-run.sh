#!/bin/bash -e

#install -m 644 files/resolv.conf "${ROOTFS_DIR}/etc/"

on_chroot <<CHEOF
    # Enable dynamically assigned DNS nameservers
    ln -sf /etc/resolvconf/run/resolv.conf /etc/resolv.conf
CHEOF
