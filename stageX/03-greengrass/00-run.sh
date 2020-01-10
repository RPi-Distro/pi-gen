#!/bin/bash -e

install -m 755 files/install-greengrass.sh "${ROOTFS_DIR}/bin/"
install -m 644 files/greengrass.service /etc/systemd/system/greengrass.service
install -m 755 files/S02greengrass /etc/init.d/S02greengrass

on_chroot << EOF
/bin/install-greengrass.sh bootstrap-greengrass
modprobe configs
systemctl enable greengrass.service
EOF
