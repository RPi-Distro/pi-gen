#!/bin/bash -e

# Enable password-less sudo for everyone
echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> "${ROOTFS_DIR}/etc/sudoers"