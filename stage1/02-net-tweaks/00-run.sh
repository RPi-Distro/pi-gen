#!/bin/bash -e

install -m 644 files/ipv6.conf ${ROOTFS_DIR}/etc/modprobe.d/ipv6.conf
install -m 644 files/interfaces ${ROOTFS_DIR}/etc/network/interfaces

cat <<EOF > ${ROOTFS_DIR}/etc/hostname
${HOST_NAME}
EOF

# Append hostname
cat <<EOF >> ${ROOTFS_DIR}/etc/hosts

127.0.1.1	${HOST_NAME}
EOF

on_chroot sh -e - <<EOF
dpkg-divert --add --local /lib/udev/rules.d/75-persistent-net-generator.rules
EOF
