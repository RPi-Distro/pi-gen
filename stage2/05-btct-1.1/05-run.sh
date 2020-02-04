#!/bin/sh -e

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/pi-zero"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/index/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/chainstate/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/sporks/"

install -v -o 1000 -g 1000 -m 755 files/btct* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/"
install -v -o 1000 -g 1000 -m 755 files/pi-zero/btct* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/btct/bin/pi-zero/"

install -v -o 1000 -g 1000 -m 700 bootstrap/blocks/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/"
install -v -o 1000 -g 1000 -m 700 bootstrap/index/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/blocks/index/"
install -v -o 1000 -g 1000 -m 700 bootstrap/chainstate/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/chainstate/"
install -v -o 1000 -g 1000 -m 700 bootstrap/sporks/* "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.btct/sporks/" 
