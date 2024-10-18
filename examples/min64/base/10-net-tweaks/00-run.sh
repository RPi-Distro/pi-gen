#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.1.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

cat << EOF > ${ROOTFS_DIR}/etc/systemd/network/01-end0.network
[Match]
Name=end0

[Network]
DHCP=yes

[DHCPv4]
RoutesToDNS=false
EOF

on_chroot << EOF
	systemctl enable systemd-networkd
EOF
