#!/bin/bash -e

export NODE_SERVICE_DIR=node-service

git clone https://github.com/node-red/raspbian-deb-package.git ${NODE_SERVICE_DIR}

install -m 644 ${NODE_SERVICE_DIR}/resources/nodered.service ${ROOTFS_DIR}/lib/systemd/system/
install -m 755 ${NODE_SERVICE_DIR}/resources/node-red-start  ${ROOTFS_DIR}/usr/bin
install -m 755 ${NODE_SERVICE_DIR}/resources/node-red-stop   ${ROOTFS_DIR}/usr/bin
install -m 755 ${NODE_SERVICE_DIR}/resources/node-red-log    ${ROOTFS_DIR}/usr/bin

on_chroot << EOF
systemctl enable nodered
EOF
