#!/bin/bash -e

install -m 755 files/install-greengrass.sh "${ROOTFS_DIR}/bin/"
install -m 644 files/greengrass.service "${ROOTFS_DIR}/etc/systemd/system/greengrass.service"
install -m 755 files/S02greengrass "${ROOTFS_DIR}/etc/init.d/S02greengrass"

[ -f "${ROOTFS_DIR}/etc/sysctl.d/98-rpi.conf" ] || touch "${ROOTFS_DIR}/etc/sysctl.d/98-rpi.conf" 

cat >> "${ROOTFS_DIR}/etc/sysctl.d/98-rpi.conf" << EOF
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF

wget -c -q -O greengrass.tar.gz "https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/1.10.0/greengrass-linux-armv7l-1.10.0.tar.gz"
tar xfvz greengrass.tar.gz -C ${ROOTFS_DIR}/
rm -f greengrass.tar.gz
wget -O ${ROOTFS_DIR}//greengrass/certs/root.ca.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

on_chroot << EOF
adduser --system ggc_user
addgroup --system ggc_group
systemctl enable greengrass.service
EOF
