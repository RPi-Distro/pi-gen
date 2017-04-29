#!/bin/bash -e
IMG_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img"

IMGID="$(fdisk -l ${IMG_FILE} | sed -n 's/Disk identifier: 0x\([^ ]*\)/\1/p')"

BOOT_PARTUUID="${IMGID}-01"
ROOT_PARTUUID="${IMGID}-02"

sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" ${ROOTFS_DIR}/etc/fstab
sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" ${ROOTFS_DIR}/etc/fstab

sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" ${ROOTFS_DIR}/boot/cmdline.txt
