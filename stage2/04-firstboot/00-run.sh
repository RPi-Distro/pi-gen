#!/bin/bash
set -e

echo ">>> Configuring production CM4 image"

# -------------------------------------------------
# 1. Install your application files into IMAGE
# -------------------------------------------------
install -d "${ROOTFS_DIR}/opt/azenta-debs"
install -d "${ROOTFS_DIR}/etc/systemd/system"

install -m 644 files/*.deb "${ROOTFS_DIR}/opt/azenta-debs/"
install -m 755 files/first-boot.sh "${ROOTFS_DIR}/etc/first-boot.sh"
install -m 644 files/first-boot.service "${ROOTFS_DIR}/etc/systemd/system/first-boot.service"

# -------------------------------------------------
# 2. Enable first boot service inside image
# -------------------------------------------------
on_chroot << EOF
systemctl enable first-boot.service
EOF

echo ">>> CM4 production setup complete"
