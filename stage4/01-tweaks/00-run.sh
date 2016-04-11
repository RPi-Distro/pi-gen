#!/bin/bash -e

ln -sf /etc/systemd/system/autologin@.service ${ROOTFS_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service

install -v -m 644 files/40-scratch.rules ${ROOTFS_DIR}/etc/udev/rules.d/
