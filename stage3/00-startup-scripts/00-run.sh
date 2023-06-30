#!/bin/bash -e

mkdir "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts"
install -m 700 files/get-config-script "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/"
install -m 644 files/farm-environment "${ROOTFS_DIR}/etc/"
install -m 644 files/hostname-gen.service "${ROOTFS_DIR}/etc/system/systemd/"

chown 1000:1000 "${ROOTFS_DIR}/tmp/get-config-script"
chown 1000:1000 "${ROOTFS_DIR}/etc/farm-environment"

ln -sv "/etc/system/systemd/hostname-gen.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/hostname-gen.service"

curl http://cdn.get.legato/tools/testbench/vpn/global/latest/global-vpn.tgz -o "global-vpn.tgz"
mkdir global-vpn
tar zxvf global-vpn.tgz --directory "global-vpn"
deb_file=$(ls global-vpn/GlobalProtect_deb_arm*.deb)
install -m 644 $deb_file "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/$(basename $deb_file)"

on_chroot << EOF
sudo bash -c "yes | dpkg -i ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/$(basename $deb_file)"
EOF
