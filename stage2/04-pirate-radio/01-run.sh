#!/bin/bash -e

install -v -m 644 files/pusleaudio.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/client.conf		"${ROOTFS_DIR}/etc/pulse/"
install -v -m 644 files/default.pa		"${ROOTFS_DIR}/etc/pulse/"
