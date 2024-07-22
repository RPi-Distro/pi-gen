#!/bin/bash -e

install -v -m 644 files/default.pa "${ROOTFS_DIR}/etc/pulse/default.pa"

on_chroot << EOF
  SUDO_USER="${FIRST_USER_NAME}" systemctl --user enable pulseaudio
EOF
