#!/bin/bash -e

install -v -m 644 files/default.pa "${ROOTFS_DIR}/etc/pulse/default.pa"

on_chroot << EOF
    /bin/su - "${FIRST_USER_NAME}" -c 'systemctl --user enable pulseaudio'
EOF
