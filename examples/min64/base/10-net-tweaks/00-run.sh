#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.1.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_net_names 1
EOF

cat << EOF > ${ROOTFS_DIR}/etc/systemd/network/01-eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes

[DHCPv4]
RoutesToDNS=false
EOF

on_chroot << EOF
	systemctl enable systemd-networkd
EOF
