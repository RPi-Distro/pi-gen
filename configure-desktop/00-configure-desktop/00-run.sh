#!/bin/bash -e

install -m 644 files/1.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
install -m 644 files/2.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
install -m 644 files/3.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
install -m 644 files/4.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper/"
mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/"
install -m 644 files/Qtum.desktop "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/"

on_chroot << EOF
#sed -ri 's,wallpaper=.*?,wallpaper=/usr/share/rpd-wallpaper/1.png,' /etc/lightdm/pi-greeter.conf
sed -ri 's,wallpaper=.*?,wallpaper=/usr/share/rpd-wallpaper/1.png,' /etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf
EOF
