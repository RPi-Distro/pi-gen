#!/bin/bash -e

install -v -o 1000 -g 29 -m 775 -d "${ROOTFS_DIR}/media/USB"
install -v -m files/mpd.conf "${ROOTFS_DIR}/etc/mpd.conf"
sed -i "s/TARGET_HOSTNAME/${TARGET_HOSTNAME}/g" "${ROOTFS_DIR}/etc/mpd.conf"

on_chroot << EOF
  SUDO_USER="${FIRST_USER_NAME}" systemctl --user enable mpd
  systemctl disable --now mpd
EOF
