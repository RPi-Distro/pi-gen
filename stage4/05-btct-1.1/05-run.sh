#!/bin/sh -e

install -v -m 644 "files/raspi.jpg" "${ROOTFS_DIR}/usr/share/rpd-wallpaper/raspi.jpg"
install -v -m 644 "files/btct-ico.xpm" "${ROOTFS_DIR}/usr/share/pixmaps/btct-ico.xpm"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/menus/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/share/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/share/applications/"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/chainstate/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/sporks/"

install -v -o 1000 -g 1000 -m 755 files/btct* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/"
install -v -o 1000 -g 1000 -m 644 files/lxde-pi-applications.menu "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/menus/"
install -v -o 1000 -g 1000 -m 644 files/desktop-items-0.conf "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/"
install -v -o 1000 -g 1000 -m 644 files/alacarte-made.desktop "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/share/applications/"

install -v -o 1000 -g 1000 -m 700 bootstrap/blocks/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/"
install -v -o 1000 -g 1000 -m 700 bootstrap/chainstate/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/chainstate/"
install -v -o 1000 -g 1000 -m 700 bootstrap/sporks/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/sporks/" 
