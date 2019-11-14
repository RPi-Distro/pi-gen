#!/bin/bash -e

# Setup an static ip to wlan0
install -v files/dhcpcd.conf ${ROOTFS_DIR}/etc/dhcpcd.conf
# Setup dhcp server for rpi to serve clients
install -v files/dnsmasq.conf ${ROOTFS_DIR}/etc/dnsmasq.conf
# Setup access point in hostapd/hostapd.conf
install -v files/hostapd.conf ${ROOTFS_DIR}/etc/hostapd/hostapd.conf
# Point default/hostapd conf to hostapd/hostapd.conf
sed -i "s@#DAEMON_CONF=\"\"@DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"@" "${ROOTFS_DIR}/etc/default/hostapd"
