#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then
	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	unmount_image "${IMG_FILE}"

	rm -f "${IMG_FILE}"

	rm -rf "${ROOTFS_DIR}"
	mkdir -p "${ROOTFS_DIR}"

	BOOT_SIZE="$((512 * 1024 * 1024))"
	ROOT_SIZE=$(du --apparent-size -s "${EXPORT_ROOTFS_DIR}" --exclude var/cache/apt/archives --exclude boot/firmware --block-size=1 | cut -f 1)

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
	IMG_SIZE=$((BOOT_PART_START + BOOT_PART_SIZE + ROOT_PART_SIZE + ALIGN))

	truncate -s "${IMG_SIZE}" "${IMG_FILE}"

	parted --script "${IMG_FILE}" mklabel gpt
	parted --script "${IMG_FILE}" unit B mkpart primary fat32 "${BOOT_PART_START}" "$((BOOT_PART_START + BOOT_PART_SIZE - 1))"
	parted --script "${IMG_FILE}" unit B mkpart primary btrfs "${ROOT_PART_START}" "$((ROOT_PART_START + ROOT_PART_SIZE - 1))"

	echo "Creating loop device..."
	cnt=0
	until ensure_next_loopdev && LOOP_DEV="$(losetup --show --find --partscan "$IMG_FILE")"; do
		if [ $cnt -lt 5 ]; then
			cnt=$((cnt + 1))
			echo "Error in losetup.  Retrying..."
			sleep 5
		else
			echo "ERROR: losetup failed; exiting"
			exit 1
		fi
	done

	ensure_loopdev_partitions "$LOOP_DEV"
	BOOT_DEV="${LOOP_DEV}p1"
	ROOT_DEV="${LOOP_DEV}p2"

	mkdosfs -n bootfs -F 32 -s 4 -v "$BOOT_DEV" > /dev/null
	mkfs.btrfs -L rootfs "$ROOT_DEV" > /dev/null

	# Create subvolumes for common directories
	mount -v "$ROOT_DEV" "${ROOTFS_DIR}" -t btrfs
	cd "${ROOTFS_DIR}"
	btrfs subvolume create @
	btrfs subvolume create @home
	btrfs subvolume create @var-lib
	cd -
	umount "${ROOTFS_DIR}"

	mount -v "$ROOT_DEV" "${ROOTFS_DIR}" -t btrfs -o subvol=@
	mkdir -p "${ROOTFS_DIR}/home" "${ROOTFS_DIR}/var/lib" "${ROOTFS_DIR}/boot/firmware"

	mount -v "$ROOT_DEV" "${ROOTFS_DIR}/home" -t btrfs -o subvol=@home
	mount -v "$ROOT_DEV" "${ROOTFS_DIR}/var/lib" -t btrfs -o subvol=@var-lib
	mount -v "$BOOT_DEV" "${ROOTFS_DIR}/boot/firmware" -t vfat

	rsync -aHAXx --exclude /var/cache/apt/archives --exclude /boot/firmware "${EXPORT_ROOTFS_DIR}/" "${ROOTFS_DIR}/"
	rsync -rtx "${EXPORT_ROOTFS_DIR}/boot/firmware/" "${ROOTFS_DIR}/boot/firmware/"
fi
