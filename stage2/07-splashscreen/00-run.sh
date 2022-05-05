#!/bin/bash
# install pionix splash screen

# splash screen config.txt options
echo "[all]" >> "${ROOTFS_DIR}/boot/config.txt"
echo "disable_splash=1" >> "${ROOTFS_DIR}/boot/config.txt"
echo "" >> "${ROOTFS_DIR}/boot/config.txt"

# splash screen cmdline options
echo -n " logo.nologo" >> "${ROOTFS_DIR}/boot/cmdline.txt"

#on_chroot <<EOF
#depmod -a 5.15.32-v7l+
#echo dm-verity >> /etc/modules
#EOF


