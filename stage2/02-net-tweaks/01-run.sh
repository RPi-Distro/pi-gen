#!/bin/bash -e

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

sed -i 's/-a nymea -p nymea-box/-a "Raspberry Pi" -p "Raspberry Pi"/' ${ROOTFS_DIR}/lib/systemd/system/nymea-networkmanager.service
