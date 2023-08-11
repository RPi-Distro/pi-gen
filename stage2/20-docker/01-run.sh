#!/bin/bash -e

install -D -m 644 files/docker-daemon.json "${ROOTFS_DIR}/etc/docker/daemon.json"
install -D -m 644 files/needrestart-kernel.conf "${ROOTFS_DIR}/etc/needrestart/conf.d/kernel.conf"
install -d "${ROOTFS_DIR}/home/docker"
