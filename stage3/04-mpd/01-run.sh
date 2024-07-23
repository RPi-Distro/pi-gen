#!/bin/bash -e

install -v -o 1000 -g 29 -m 775 -d "${ROOTFS_DIR}/media/USB"

install -v -o 1000 -g 1000 -m 775 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/mpd"
install -v -o 1000 -g 1000 -m 775 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/mpd/playlists"
install -v -m 644 /dev/null "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/mpd/state"
install -v -o 1000 -g 1000 -m 644 files/mpd.conf "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/mpd/mpd.conf"
sed -i "s/TARGET_HOSTNAME/${TARGET_HOSTNAME}/g" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/mpd/mpd.conf"

on_chroot << EOF
  systemctl disable mpd
  /bin/su - "${FIRST_USER_NAME}" -c 'systemctl --user enable mpd'
EOF
