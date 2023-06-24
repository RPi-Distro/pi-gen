#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then
	IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	unmount_image "${IMG_FILE}"

	rm -f "${IMG_FILE}"

	rm -rf "${ROOTFS_DIR}"
	mkdir -p "${ROOTFS_DIR}"

	MEGABYTE="$((1024 * 1024))"

	BOOT_SIZE="$((256 * $MEGABYTE))"
	ROOT_SIZE=$(du --apparent-size -s "${EXPORT_ROOTFS_DIR}" --exclude var/cache/apt/archives --exclude boot --block-size=1 | cut -f 1)
	WORK_SIZE="$(($WORK_PARTITION_SIZE * $MEGABYTE))"
	DEPLOY_SIZE="$(($DEPLOY_PARTITION_SIZE * $MEGABYTE))"

	# All partition sizes and starts will be aligned to this size
	ALIGN="$((4 * 1024 * 1024))"
	# Add this much space to the calculated file size. This allows for
	# some overhead (since actual space usage is usually rounded up to the
	# filesystem block size) and gives some free space on the resulting
	# image.
	ROOT_MARGIN="$(echo "($ROOT_SIZE * 0.2 + $ROOT_PART_EXTRA_SPACE * ${MEGABYTE}) / 1" | bc)"

	BOOT_PART_START=$((ALIGN))
	BOOT_PART_SIZE=$(((BOOT_SIZE + ALIGN - 1) / ALIGN * ALIGN))
	DEPLOY_PART_START=$((BOOT_PART_START + BOOT_PART_SIZE))
	DEPLOY_PART_SIZE=$(((DEPLOY_SIZE + ALIGN  - 1) / ALIGN * ALIGN))
	WORK_PART_START=$((DEPLOY_PART_START + DEPLOY_PART_SIZE))
	WORK_PART_SIZE=$(((WORK_SIZE + ALIGN  - 1) / ALIGN * ALIGN))
	ROOT_PART_START=$((WORK_PART_START + WORK_PART_SIZE))
	ROOT_PART_SIZE=$(((ROOT_SIZE + ROOT_MARGIN + ALIGN  - 1) / ALIGN * ALIGN))

	IMG_SIZE=$((BOOT_PART_START + BOOT_PART_SIZE + DEPLOY_PART_SIZE + WORK_PART_SIZE + ROOT_PART_SIZE))

	echo Creating paritions:
	
	truncate -s "${IMG_SIZE}" "${IMG_FILE}"

	parted --script "${IMG_FILE}" mklabel msdos
	echo BOOT: start="$(($BOOT_PART_START / $MEGABYTE))"MB size="$(( (BOOT_PART_SIZE - 1 ) / $MEGABYTE))"MB
	parted --script "${IMG_FILE}" unit B mkpart primary fat32 "${BOOT_PART_START}" "$((BOOT_PART_START + BOOT_PART_SIZE - 1))"
	echo DEPLOY: start="$(($DEPLOY_PART_START / $MEGABYTE))"MB size="$(( (DEPLOY_PART_SIZE - 1 ) / $MEGABYTE))"MB
	parted --script "${IMG_FILE}" unit B mkpart primary fat32 "${DEPLOY_PART_START}" "$((DEPLOY_PART_START + DEPLOY_PART_SIZE - 1))"
	echo WORK: start="$(($WORK_PART_START / $MEGABYTE))"MB size="$(( (WORK_PART_SIZE - 1 ) / $MEGABYTE))"MB
	parted --script "${IMG_FILE}" unit B mkpart primary ext4 "${WORK_PART_START}" "$((WORK_PART_START + WORK_PART_SIZE - 1))"
	echo ROOT: start="$(($ROOT_PART_START / $MEGABYTE))"MB size="$(( (ROOT_PART_SIZE - 1 ) / $MEGABYTE))"MB
	parted --script "${IMG_FILE}" unit B mkpart primary ext4 "${ROOT_PART_START}" "$((ROOT_PART_START + ROOT_PART_SIZE - 1))"

	echo TOTAL IMAGE SIZE: $(($IMG_SIZE / $MEGABYTE))MB

	echo "Creating loop device..."
	cnt=0
	until LOOP_DEV="$(losetup --show --find --partscan "$IMG_FILE")"; do
		if [ $cnt -lt 5 ]; then
			cnt=$((cnt + 1))
			echo "Error in losetup.  Retrying..."
			sleep 5
		else
			echo "ERROR: losetup failed; exiting"
			exit 1
		fi
	done

	BOOT_DEV="${LOOP_DEV}p1"
	ROOT_DEV="${LOOP_DEV}p4"
	DEPLOY_DEV="${LOOP_DEV}p2"
	WORK_DEV="${LOOP_DEV}p3"

	ROOT_FEATURES="^huge_file"
	for FEATURE in 64bit; do
	if grep -q "$FEATURE" /etc/mke2fs.conf; then
		ROOT_FEATURES="^$FEATURE,$ROOT_FEATURES"
	fi
	done

	echo "Formatting filesystems..."
	mkdosfs -n bootfs -F 32 -s 4 -v "$BOOT_DEV" > /dev/null
	mkdosfs -n deploy -F 32 -s 4 -v "$DEPLOY_DEV" > /dev/null
	mkfs.ext4 -L work -O "$ROOT_FEATURES" "$WORK_DEV" > /dev/null
	mkfs.ext4 -L rootfs -O "$ROOT_FEATURES" "$ROOT_DEV" > /dev/null

	mount -v "$ROOT_DEV" "${ROOTFS_DIR}" -t ext4
	mkdir -p "${ROOTFS_DIR}/boot"
	mount -v "$BOOT_DEV" "${ROOTFS_DIR}/boot" -t vfat
	
	rsync -aHAXx --exclude /var/cache/apt/archives --exclude /boot --exclude /srv/sth --exclude /opt/sth/deploy "${EXPORT_ROOTFS_DIR}/" "${ROOTFS_DIR}/"
	rsync -rtx "${EXPORT_ROOTFS_DIR}/boot/" "${ROOTFS_DIR}/boot/"

	if [[ -d "${EXPORT_ROOTFS_DIR}/srv/sth" ]]; then
		mkdir "${ROOTFS_DIR}/srv/sth" 
		mkdir "${ROOTFS_DIR}/opt/sth/deploy"

		mount -v "$WORK_DEV" "${ROOTFS_DIR}/srv/sth" -t ext4
		mount -v "$DEPLOY_DEV" "${ROOTFS_DIR}/opt/sth/deploy" -t vfat
		rsync -rtx "${EXPORT_ROOTFS_DIR}/srv/sth" "${ROOTFS_DIR}/srv/sth/"
		rsync -rtx "${EXPORT_ROOTFS_DIR}/srv/sth" "${ROOTFS_DIR}/opt/sth/deploy/"
	fi
fi
