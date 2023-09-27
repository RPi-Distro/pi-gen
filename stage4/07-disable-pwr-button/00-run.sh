#!/bin/bash -e

sed -i 's/^.*HandlePowerKey=.*$/HandlePowerKey=ignore/' "${ROOTFS_DIR}/etc/systemd/logind.conf"
