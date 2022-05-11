#!/bin/bash -e

#install -m 755 files/install_update "${ROOTFS_DIR}/usr/bin"
#install -m 644 files/boot-mark-good.service "${ROOTFS_DIR}/lib/systemd/system/"
install -m 755 files/ota-update-daemon.sh "${ROOTFS_DIR}/usr/bin"
install -m 644 files/ota-update-timer.service "${ROOTFS_DIR}/lib/systemd/system/"
install -m 644 files/ota-update.service "${ROOTFS_DIR}/lib/systemd/system/"

on_chroot <<EOF
# create update meta data
cat > /etc/update.meta <<XOF
{
  "update": {
    "hwid": "${HW_ID}",
    "version": ${IMG_TIMESTAMP},
    "description": "${IMG_DESCRIPTION}",
    "download_uri": "https://pionix-update.de/${HW_ID}/${UPDATE_CHANNEL}/${IMG_FILENAME}.pnx"
  }
}
XOF
systemctl enable ota-update-timer.service
EOF

