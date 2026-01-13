#!/bin/bash -e

# Install systemd service
install -m 644 files/garden_back.service "${ROOTFS_DIR}/etc/systemd/system/"

# Install lighttpd proxy configuration
install -m 644 files/10-gardenback-proxy.conf "${ROOTFS_DIR}/etc/lighttpd/conf-available/"

# Install mosquitto configuration
install -m 644 files/mosquitto.conf "${ROOTFS_DIR}/etc/mosquitto/conf.d/"

# Install environment configuration
install -m 644 files/.env "${ROOTFS_DIR}/opt/gardenback/"

on_chroot << EOF
# Enable lighttpd proxy module
lighty-enable-mod proxy

# Enable GardenBack proxy configuration
ln -sf /etc/lighttpd/conf-available/10-gardenback-proxy.conf /etc/lighttpd/conf-enabled/10-gardenback-proxy.conf

# Enable services
systemctl enable garden_back.service
systemctl enable mosquitto.service
systemctl enable lighttpd.service
EOF