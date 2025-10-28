#!/bin/bash -e

# Replace Raspberry Pi artwork with Computado Rita artwork
install -m 644 files/raspberrypi-artwork/raspberry-pi-logo.png "${ROOTFS_DIR}/usr/share/raspberrypi-artwork/"
install -m 644 files/raspberrypi-artwork/raspberry-pi-logo-small.png "${ROOTFS_DIR}/usr/share/raspberrypi-artwork/"
install -m 644 files/raspberrypi-artwork/raspberry-pi-logo.svg "${ROOTFS_DIR}/usr/share/raspberrypi-artwork/"

# Replace wallpapers
install -m 644 files/rpd-wallpaper/RPiSystem.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
install -m 644 files/rpd-wallpaper/RPiSystem_dark.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
