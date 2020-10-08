#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.1.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"
printf "%s\t%s\t%s\n" '192.168.0.110' 'rpi4b-1.1stcall.uk' 'rpi4b-1' | tee -a "${ROOTFS_DIR}/etc/hosts"
printf "%s\t%s\t%s\n" '192.168.0.120' 'rpi4b-2.1stcall.uk' 'rpi4b-2' | tee -a "${ROOTFS_DIR}/etc/hosts"
printf "%s\t%s\t%s\n" '192.168.0.130' 'rpi4b-3.1stcall.uk' 'rpi4b-3' | tee -a "${ROOTFS_DIR}/etc/hosts"
printf "%s\t%s\t%s\n" '192.168.0.140' 'rpi4b-4.1stcall.uk' 'rpi4b-4' | tee -a "${ROOTFS_DIR}/etc/hosts"

ln -sf /dev/null "${ROOTFS_DIR}/etc/systemd/network/99-default.link"
