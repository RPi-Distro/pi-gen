#!/bin/bash -e

install -v -m 644 files/pulseaudio.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/client.conf		"${ROOTFS_DIR}/etc/pulse/"
install -v -m 644 files/default.pa		"${ROOTFS_DIR}/etc/pulse/"

cp -rf	 files/pivumeter			"${ROOTFS_DIR}/root/"
install -v -m 644 files/pivumeter/dependencies/etc/asound.conf	"${ROOTFS_DIR}/etc/"
install -v -m 755 files/vlcd			"${ROOTFS_DIR}/etc/init.d/"
install -v -m 755 files/bin/vlcd		"${ROOTFS_DIR}/usr/bin/"
mkdir "${ROOTFS_DIR}/etc/vlcd"
if [ -f ../../my-playlist.m3u ]; then
	install -v -m 644 ../../my-playlist.m3u	"${ROOTFS_DIR}/etc/vlcd/default.m3u"
else
	install -v -m 644 files/default.m3u		"${ROOTFS_DIR}/etc/vlcd/"
fi
install -v -m 755 files/phatbeatd		"${ROOTFS_DIR}/etc/init.d/"
install -v -m 755 files/bin/phatbeatd		"${ROOTFS_DIR}/usr/bin/"
