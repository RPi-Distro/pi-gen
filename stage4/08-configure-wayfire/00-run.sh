#!/bin/bash -e

sed -i 's/^mouse_snap = .*$/mouse_snap = true/' "${ROOTFS_DIR}/etc/wayfire/defaults.ini"
