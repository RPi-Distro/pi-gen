#!/bin/bash -e

install -m 644 files/user-data ${ROOTFS_DIR}/boot/
install -m 644 files/meta-data ${ROOTFS_DIR}/boot/
install -m 644 files/cloud/cloud.cfg ${ROOTFS_DIR}/etc/cloud/

on_chroot << EOF
echo 'Get cloud-init'

echo 'Symlinking cloud-init nocloud-net seed files to /boot partition'
mkdir -p /var/lib/cloud/seed/nocloud-net
if [ ! -f /var/lib/cloud/seed/nocloud-net/user-data ]
then
  ln -s /boot/user-data /var/lib/cloud/seed/nocloud-net/user-data
fi
if [ ! -f /var/lib/cloud/seed/nocloud-net/meta-data ]
then
  ln -s /boot/meta-data /var/lib/cloud/seed/nocloud-net/meta-data
fi
EOF
