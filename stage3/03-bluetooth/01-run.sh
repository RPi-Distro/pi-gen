#!/bin/bash -e

install -v -m 644 files/bluetooth/main.conf "${ROOTFS_DIR}/etc/bluetooth/main.conf"
sed -i "s/TARGET_HOSTNAME/${TARGET_HOSTNAME}/g" "${ROOTFS_DIR}/etc/bluetooth/main.conf"

install -v -m 600 files/bluetooth/pin.conf "${ROOTFS_DIR}/etc/bluetooth/pin.conf"
install -v -m 644 files/bt-agent.service "${ROOTFS_DIR}/etc/systemd/system/bt-agent.service"

install -v -m 644 files/success.wav "${ROOTFS_DIR}/usr/local/share/success.wav"
install -v -m 755 files/bt-connection.sh "${ROOTFS_DIR}/usr/local/bin/bt-connection.sh"
install -v -m 644 files/99-local.rules "${ROOTFS_DIR}/etc/udev/rules.d/99-local.rules"

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" systemctl --user restart pulseaudio
	udevadm control --reload-rules
	systemctl daemon-reload
	systemctl enable bt-agent
EOF
