#!/bin/bash -e

NOOBS_DIR="${STAGE_WORK_DIR}/${IMG_NAME}${IMG_SUFFIX}"
mkdir -p "${STAGE_WORK_DIR}"

if [ "${DEPLOY_ZIP}" == "1" ]; then
	IMG_FILE="${WORK_DIR}/export-image/${IMG_FILENAME}${IMG_SUFFIX}.img"
else
	IMG_FILE="${DEPLOY_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"
fi

unmount_image "${IMG_FILE}"

rm -rf "${NOOBS_DIR}"

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

mkdir -p "${STAGE_WORK_DIR}/rootfs"
mkdir -p "${NOOBS_DIR}"

mount "$ROOT_DEV" "${STAGE_WORK_DIR}/rootfs"
mount "$BOOT_DEV" "${STAGE_WORK_DIR}/rootfs/boot"

ln -sv "/lib/systemd/system/apply_noobs_os_config.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/apply_noobs_os_config.service"

KERNEL_VER="$(zgrep -oPm 1 "Linux version \K(.*)$" "${STAGE_WORK_DIR}/rootfs/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz" | cut -f-2 -d.)"
echo "$KERNEL_VER" > "${STAGE_WORK_DIR}/kernel_version"

bsdtar --numeric-owner --format gnutar -C "${STAGE_WORK_DIR}/rootfs/boot" -cpf - . | xz -T0 > "${NOOBS_DIR}/boot.tar.xz"
umount "${STAGE_WORK_DIR}/rootfs/boot"
bsdtar --numeric-owner --format gnutar -C "${STAGE_WORK_DIR}/rootfs" --one-file-system -cpf - . | xz -T0 > "${NOOBS_DIR}/root.tar.xz"

if [ "${USE_QCOW2}" = "1" ]; then
	rm "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/apply_noobs_os_config.service"
fi

unmount_image "${IMG_FILE}"
