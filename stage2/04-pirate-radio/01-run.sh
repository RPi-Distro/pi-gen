#!/bin/bash -e

install -v -m 644 files/pulseaudio.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/client.conf		"${ROOTFS_DIR}/etc/pulse/"
install -v -m 644 files/default.pa		"${ROOTFS_DIR}/etc/pulse/"

cp -rf	 files/pivumeter			"${ROOTFS_DIR}/root/"
install -v -m 644 files/pivumeter/dependencies/etc/asound.conf	"${ROOTFS_DIR}/etc/"
