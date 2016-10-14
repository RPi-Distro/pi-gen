#!/bin/bash -e

on_chroot sh -e - <<EOF
update-alternatives --install /usr/share/images/desktop-base/desktop-background \
desktop-background /usr/share/raspberrypi-artwork/raspberry-pi-logo.png 100
EOF

rm -f ${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/wait.conf
