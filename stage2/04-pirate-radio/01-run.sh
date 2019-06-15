#!/bin/bash -e

# set hostname
install -v -m 644 files/etc/hostname					"${ROOTFS_DIR}/etc/"
install -v -m 644 files/etc/hosts					"${ROOTFS_DIR}/etc/"

# pulseaudio
install -v -m 644 files/etc/systemd/system/pulseaudio.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/etc/pulse/client.conf				"${ROOTFS_DIR}/etc/pulse/"
install -v -m 644 files/etc/pulse/default.pa				"${ROOTFS_DIR}/etc/pulse/"

# pivumeter
git clone https://github.com/pimoroni/pivumeter.git			"${ROOTFS_DIR}/root/pivumeter"
install -v -m 644 "${ROOTFS_DIR}/root/pivumeter/dependencies/etc/asound.conf"		"${ROOTFS_DIR}/etc/"

# mpd
git clone https://github.com/Mic92/python-mpd2.git			"${ROOTFS_DIR}/root/python-mpd2"
install -v -m 644 files/etc/mpd.conf					"${ROOTFS_DIR}/etc/"
if [ -f ../../my-playlist.m3u ]; then
	install -v -m 644 ../../my-playlist.m3u				"${ROOTFS_DIR}/var/lib/mpd/playlists/my-playlist.m3u"
fi

# physical interface
install -v -m 644 files/etc/systemd/system/radio-interface.service	"${ROOTFS_DIR}/etc/systemd/system/"
mkdir "${ROOTFS_DIR}/usr/local/lib/radio-interface/"
install -v -m 644 files/interface.py					"${ROOTFS_DIR}/usr/local/lib/radio-interface/"

# web interface
install -v -m 644 files/etc/systemd/system/ympd.service			"${ROOTFS_DIR}/etc/systemd/system/"
git clone https://github.com/notandy/ympd.git				"${ROOTFS_DIR}/root/ympd"
