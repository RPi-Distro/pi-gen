#!/bin/bash -e

# Install the service so the system can run it
install -m 755 files/vision.service "${ROOTFS_DIR}/etc/systemd/system"

on_chroot << EOF
# Reload the system services
sudo systemctl daemon-reload

# Enable our vision service on startup
sudo systemctl enable vision
EOF
