#!/bin/bash -e

install -v -m 644 files/bluetooth.conf "${ROOTFS_DIR}/etc/bluetooth/bluetooth.conf"
install -v -m 600 files/pin.conf "${ROOTFS_DIR}/etc/bluetooth/pin.conf"

on_chroot << EOF
  SUDO_USER="${FIRST_USER_NAME}" systemctl --user enable pulseaudio
EOF
