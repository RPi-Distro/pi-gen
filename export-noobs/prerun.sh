#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img"
NOOBS_DIR="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}"
unmount_image "${IMG_FILE}"

mkdir -p "${STAGE_WORK_DIR}"
cp "${WORK_DIR}/export-image/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img" "${STAGE_WORK_DIR}/"

rm -rf "${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}"

PARTED_OUT=$(parted -s "${IMG_FILE}" unit b print)
BOOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 1'| xargs echo -n \
| cut -d" " -f 2 | tr -d B)
BOOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 1'| xargs echo -n \
| cut -d" " -f 4 | tr -d B)

ROOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 2'| xargs echo -n \
| cut -d" " -f 2 | tr -d B)
ROOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 2'| xargs echo -n \
| cut -d" " -f 4 | tr -d B)

BOOT_DEV=$(losetup --show -f -o "${BOOT_OFFSET}" --sizelimit "${BOOT_LENGTH}" "${IMG_FILE}")
ROOT_DEV=$(losetup --show -f -o "${ROOT_OFFSET}" --sizelimit "${ROOT_LENGTH}" "${IMG_FILE}")
echo "/boot: offset $BOOT_OFFSET, length $BOOT_LENGTH"
echo "/:     offset $ROOT_OFFSET, length $ROOT_LENGTH"

mkdir -p "${STAGE_WORK_DIR}/rootfs"
mkdir -p "${NOOBS_DIR}"

mount "$ROOT_DEV" "${STAGE_WORK_DIR}/rootfs"
mount "$BOOT_DEV" "${STAGE_WORK_DIR}/rootfs/boot"

ln -sv "/lib/systemd/system/apply_noobs_os_config.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/apply_noobs_os_config.service"

bsdtar --numeric-owner --format gnutar --use-compress-program pxz -C "${STAGE_WORK_DIR}/rootfs/boot" -cpf "${NOOBS_DIR}/boot.tar.xz" .
umount "${STAGE_WORK_DIR}/rootfs/boot"
bsdtar --numeric-owner --format gnutar --use-compress-program pxz -C "${STAGE_WORK_DIR}/rootfs" --one-file-system -cpf "${NOOBS_DIR}/root.tar.xz" .

unmount_image "${IMG_FILE}"
