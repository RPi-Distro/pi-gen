#!/bin/bash -e

install -v -m files/default.pa "${ROOTFS_DIR}/etc/pulseaudio/default.pa"

on_chroot << EOF
  SUDO_USER="${FIRST_USER_NAME}" systemctl --user enable pulseaudio
EOF
