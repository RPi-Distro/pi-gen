#!/bin/bash

install -d "${ROOTFS_DIR}/srv/sth"
install -d "${ROOTFS_DIR}/var/log/sth"
install -d "${ROOTFS_DIR}/opt/sth/deploy"
install -d "${ROOTFS_DIR}/opt/sth/deploy/conf"
install -d "${ROOTFS_DIR}/opt/sth/deploy/sequences"

install -m 755 files/start-sth              "${ROOTFS_DIR}/usr/bin/start-sth"
install -d                                  "${ROOTFS_DIR}/etc/sth"
install -m 644 files/sth-config.json        "${ROOTFS_DIR}/etc/sth/"
install -m 644 files/sth.service            "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/sth-deploy-config.json "${ROOTFS_DIR}/opt/sth/deploy/conf"

on_chroot << EOF
chown -R sth:sth /usr/lib/sth
chown -R sth:sth /srv/sth
chown -R sth:sth /var/log/sth
systemctl enable sth
EOF
