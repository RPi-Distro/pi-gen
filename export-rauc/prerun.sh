#!/bin/bash -e

RAUC_DIR="${STAGE_WORK_DIR}/${IMG_NAME}${IMG_SUFFIX}"
mkdir -p "${STAGE_WORK_DIR}"

IMG_FILE="${WORK_DIR}/export-image/${IMG_FILENAME}${IMG_SUFFIX}.img"

unmount_image "${IMG_FILE}"

rm -rf "${NOOBS_DIR}"

PARTED_OUT=$(parted -sm "${IMG_FILE}" unit b print)

ROOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^2:' | cut -d':' -f 2 | tr -d B)
ROOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^2:' | cut -d':' -f 4 | tr -d B)

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

echo "/:     offset $ROOT_OFFSET, length $ROOT_LENGTH"

mkdir -p "${STAGE_WORK_DIR}/rootfs"
mkdir -p "${RAUC_DIR}"

mount "$ROOT_DEV" "${STAGE_WORK_DIR}/rootfs"

#ln -sv "/lib/systemd/system/apply_noobs_os_config.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/apply_noobs_os_config.service"
export XZ_DEFAULTS="-T 4"
tar cJf "${RAUC_DIR}/root.tar.xz" -C"${STAGE_WORK_DIR}/rootfs" .
#bsdtar --numeric-owner --format gnutar -C "${STAGE_WORK_DIR}/rootfs" --one-file-system -cpf - . | xz -T0 > "${NOOBS_DIR}/root.tar.xz"

unmount_image "${IMG_FILE}"
