#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img"
NOOBS_DIR="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}"
unmount_image ${IMG_FILE}

mkdir -p ${STAGE_WORK_DIR}
cp ${WORK_DIR}/export-image/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img ${STAGE_WORK_DIR}/

rm -rf ${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}

LOOP_DEV=`kpartx -asv ${IMG_FILE} | grep -E -o -m1 'loop[[:digit:]]+' | head -n 1`
BOOT_DEV=/dev/mapper/${LOOP_DEV}p1
ROOT_DEV=/dev/mapper/${LOOP_DEV}p2

mkdir -p ${STAGE_WORK_DIR}/rootfs
mkdir -p ${NOOBS_DIR}

mount $ROOT_DEV ${STAGE_WORK_DIR}/rootfs
mount $BOOT_DEV ${STAGE_WORK_DIR}/rootfs/boot

tar -I pxz -C ${STAGE_WORK_DIR}/rootfs/boot -cpf ${NOOBS_DIR}/boot.tar.xz .
tar -I pxz -C ${STAGE_WORK_DIR}/rootfs --one-file-system -cpf ${NOOBS_DIR}/root.tar.xz .

unmount_image ${IMG_FILE}
