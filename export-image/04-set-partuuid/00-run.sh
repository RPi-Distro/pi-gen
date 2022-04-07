#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then

	# Pionix(CC): We should not use UUIDs here for filesystems to simplify updating with RAUC
	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	IMGID="$(dd if="${IMG_FILE}" skip=440 bs=1 count=4 2>/dev/null | xxd -e | cut -f 2 -d' ')"

	BOOT_PARTUUID="${IMGID}-01"
	ROOT_PARTUUID="${IMGID}-02"

	sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"
	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"

	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/boot/cmdline.txt"

fi

