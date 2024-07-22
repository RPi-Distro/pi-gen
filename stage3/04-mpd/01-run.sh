#!/bin/bash -e

install -v -o 1000 -g 29 -m 775 -d "${ROOTFS_DIR}/media/USB"
install -v -m 644 files/mpd.conf "${ROOTFS_DIR}/etc/mpd.conf"
sed -i "s/TARGET_HOSTNAME/${TARGET_HOSTNAME}/g" "${ROOTFS_DIR}/etc/mpd.conf"

on_chroot << EOF
  systemctl disable mpd
  /bin/su - "${FIRST_USER_NAME}" -c 'systemctl --user enable mpd'
EOF
