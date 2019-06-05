#!/bin/bash -e

# pulseaudio
install -v -m 644 files/etc/systemd/system/pulseaudio.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/etc/pulse/client.conf				"${ROOTFS_DIR}/etc/pulse/"
install -v -m 644 files/etc/pulse/default.pa				"${ROOTFS_DIR}/etc/pulse/"

# pivumeter
cp -rf files/pivumeter							"${ROOTFS_DIR}/root/"
install -v -m 644 files/pivumeter/dependencies/etc/asound.conf		"${ROOTFS_DIR}/etc/"
