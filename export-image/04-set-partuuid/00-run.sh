#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then

	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	if [ "${PARTITION_TABLE_TYPE}" == "msdos" ]; then
		IMGID="$(dd if="${IMG_FILE}" skip=440 bs=1 count=4 2>/dev/null | xxd -e | cut -f 2 -d' ')"

		BOOT_PARTUUID="${IMGID}-01"
		ROOT_PARTUUID="${IMGID}-02"
	elif [ "${PARTITION_TABLE_TYPE}" == "gpt" ]; then
		BOOT_PARTUUID="$(sgdisk -i 1 "${IMG_FILE}" | grep "Partition unique GUID" | awk '{ print tolower($NF) }')"
		ROOT_PARTUUID="$(sgdisk -i 2 "${IMG_FILE}" | grep "Partition unique GUID" | awk '{ print tolower($NF) }')"
	else
		echo "Unknown partition table type '${PARTITION_TABLE_TYPE}'. Only msdos and gpt are supported."
		exit 1
	fi

	sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"
	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"

	sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
fi

