#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then

	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	BOOT_PARTUUID="$(sgdisk -i 1 "${IMG_FILE}" | grep "Partition unique GUID" | awk '{ print tolower($NF) }')"
	ROOT_PARTUUID="$(sgdisk -i 2 "${IMG_FILE}" | grep "Partition unique GUID" | awk '{ print tolower($NF) }')"

	sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"
	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"

	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
fi

