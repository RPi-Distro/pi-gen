#!/bin/bash

install -m 755 files/start-sth          "${ROOTFS_DIR}/usr/bin/start-sth"
install -d                              "${ROOTFS_DIR}/etc/sth"
install -m 644 files/sth-config.json    "${ROOTFS_DIR}/etc/sth/"
install -m 644 files/sth.service        "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
chown -R sth:sth /usr/lib/sth
systemctl enable sth
EOF
