#!/bin/bash -e

sed -i 's/^update_initramfs=.*/update_initramfs=all/' "${ROOTFS_DIR}/etc/initramfs-tools/update-initramfs.conf"

on_chroot << EOF
update-initramfs -k all -c
if [ -x /etc/init.d/fake-hwclock ]; then
   /etc/init.d/fake-hwclock stop
fi
if hash hardlink 2>/dev/null; then
   hardlink -t /usr/share/doc
fi
apt-get update
apt-get -y dist-upgrade --auto-remove --purge
apt-get clean
EOF
