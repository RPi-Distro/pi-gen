#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then
	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	unmount_image "${IMG_FILE}"

	rm -f "${IMG_FILE}"

	rm -rf "${ROOTFS_DIR}"
	mkdir -p "${ROOTFS_DIR}"

	BOOT_SIZE="$((256 * 1024 * 1024))"
	ROOT_SIZE=$(du --apparent-size -s "${EXPORT_ROOTFS_DIR}" --exclude var/cache/apt/archives --exclude boot --block-size=1 | cut -f 1)

	# All partition sizes and starts will be aligned to this size
	ALIGN="$((4 * 1024 * 1024))"
	# Add this much space to the calculated file size. This allows for
	# some overhead (since actual space usage is usually rounded up to the
	# filesystem block size) and gives some free space on the resulting
	# image.
	ROOT_MARGIN="$(echo "($ROOT_SIZE * 0.2 + 200 * 1024 * 1024) / 1" | bc)"

	BOOT_PART_START=$((ALIGN))
	BOOT_PART_SIZE=$(((BOOT_SIZE + ALIGN - 1) / ALIGN * ALIGN))
	ROOT_PART_START=$((BOOT_PART_START + BOOT_PART_SIZE))
	ROOT_PART_SIZE=$(((ROOT_SIZE + ROOT_MARGIN + ALIGN  - 1) / ALIGN * ALIGN))
	IMG_SIZE=$((BOOT_PART_START + BOOT_PART_SIZE + ROOT_PART_SIZE))

	truncate -s "${IMG_SIZE}" "${IMG_FILE}"

	parted --script "${IMG_FILE}" mklabel msdos
	parted --script "${IMG_FILE}" unit B mkpart primary fat32 "${BOOT_PART_START}" "$((BOOT_PART_START + BOOT_PART_SIZE - 1))"
	parted --script "${IMG_FILE}" unit B mkpart primary ext4 "${ROOT_PART_START}" "$((ROOT_PART_START + ROOT_PART_SIZE - 1))"

	PARTED_OUT=$(parted -sm "${IMG_FILE}" unit b print)
	BOOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^1:' | cut -d':' -f 2 | tr -d B)
	BOOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^1:' | cut -d':' -f 4 | tr -d B)

	ROOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^2:' | cut -d':' -f 2 | tr -d B)
	ROOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^2:' | cut -d':' -f 4 | tr -d B)

	echo "Mounting BOOT_DEV..."
	cnt=0
	until BOOT_DEV=$(losetup --show -f -o "${BOOT_OFFSET}" --sizelimit "${BOOT_LENGTH}" "${IMG_FILE}"); do
		if [ $cnt -lt 5 ]; then
			cnt=$((cnt + 1))
			echo "Error in losetup for BOOT_DEV.  Retrying..."
			sleep 5
		else
			echo "ERROR: losetup for BOOT_DEV failed; exiting"
			exit 1
		fi
	done

	echo "Mounting ROOT_DEV..."
	cnt=0
	until ROOT_DEV=$(losetup --show -f -o "${ROOT_OFFSET}" --sizelimit "${ROOT_LENGTH}" "${IMG_FILE}"); do
		if [ $cnt -lt 5 ]; then
			cnt=$((cnt + 1))
			echo "Error in losetup for ROOT_DEV.  Retrying..."
			sleep 5
		else
			echo "ERROR: losetup for ROOT_DEV failed; exiting"
			exit 1
		fi
	done

	echo "/boot: offset $BOOT_OFFSET, length $BOOT_LENGTH"
	echo "/:     offset $ROOT_OFFSET, length $ROOT_LENGTH"

	ROOT_FEATURES="^huge_file"
	for FEATURE in metadata_csum 64bit; do
	if grep -q "$FEATURE" /etc/mke2fs.conf; then
		ROOT_FEATURES="^$FEATURE,$ROOT_FEATURES"
	fi
	done
	mkdosfs -n boot -F 32 -v "$BOOT_DEV" > /dev/null
	mkfs.ext4 -L rootfs -O "$ROOT_FEATURES" "$ROOT_DEV" > /dev/null

	mount -v "$ROOT_DEV" "${ROOTFS_DIR}" -t ext4
	mkdir -p "${ROOTFS_DIR}/boot"
	mount -v "$BOOT_DEV" "${ROOTFS_DIR}/boot" -t vfat

	rsync -aHAXx --exclude /var/cache/apt/archives --exclude /boot "${EXPORT_ROOTFS_DIR}/" "${ROOTFS_DIR}/"
	rsync -rtx "${EXPORT_ROOTFS_DIR}/boot/" "${ROOTFS_DIR}/boot/"
fi
