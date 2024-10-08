#!/bin/bash -e

rm -rf ${STAGE_WORK_DIR}/genimage.in
rm -rf ${STAGE_WORK_DIR}/config
mkdir -p ${STAGE_WORK_DIR}/{genimage.in,config}

rm -rf ${ROOTFS_DIR}
mkdir -p ${ROOTFS_DIR}

ROOT_DU=$(du -x --apparent-size -s "${EXPORT_ROOTFS_DIR}" --exclude var/cache/apt/archives --exclude boot/firmware --block-size=1 | cut -f 1)
ROOT_MARGIN="$(echo "($ROOT_DU * 0.2 + 50 * 1024 * 1024) / 1" | bc)"
ROOT_SIZE=$(numfmt --to=none --to-unit=1000 --format=%f --suffix=K $((ROOT_DU + ROOT_MARGIN)))

FW_DU=$(du -x --apparent-size -s "${EXPORT_ROOTFS_DIR}/boot/firmware" --block-size=1 | cut -f 1)
FW_MARGIN="$(echo "($FW_DU * 0.1  + 20 * 1024 * 1024) / 1" | bc)"
FW_SIZE=$(numfmt --to=none --to-unit=1000 --format=%f --suffix=K $((FW_DU + FW_MARGIN)))


cat << EOF > "${STAGE_WORK_DIR}/genimage.in/autoboot.txt"
[ALL]
boot_partition=2
EOF


ROOT_FEATURES="^huge_file"
for FEATURE in 64bit; do
if grep -q "$FEATURE" /etc/mke2fs.conf; then
	ROOT_FEATURES="^$FEATURE,$ROOT_FEATURES"
fi
done


trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

SLOTP_PROCESS=$(readlink -f ./AB/slot-post-process-part.sh)


cat files/genimage-parts.template | \
	sed -e "s|<FW_SIZE>|$FW_SIZE|g" \
	-e "s|<ROOT_SIZE>|$ROOT_SIZE|g" \
	-e "s|<ROOT_FEATURES>|'$ROOT_FEATURES'|g" \
	-e "s|<SLOTP>|'$SLOTP_PROCESS'|g" \
	> ${STAGE_WORK_DIR}/config/parts.cfg


rm -rf ${STAGE_WORK_DIR}/genimage.tmp
genimage \
	--rootpath ${ROOTPATH_TMP} \
	--tmppath ${STAGE_WORK_DIR}/genimage.tmp \
	--inputpath ${STAGE_WORK_DIR}/genimage.in   \
	--outputpath ${STAGE_WORK_DIR} \
	--config ${STAGE_WORK_DIR}/config/parts.cfg


for slot in A B ; do
	mount ${STAGE_WORK_DIR}/root${slot}.ext4 ${ROOTFS_DIR}
	rsync -aHAXx --exclude /var/cache/apt/archives --exclude /boot/firmware ${EXPORT_ROOTFS_DIR}/ ${ROOTFS_DIR}/

	mount --mkdir ${STAGE_WORK_DIR}/boot${slot}.vfat ${ROOTFS_DIR}/boot/firmware
	rsync -rtx ${EXPORT_ROOTFS_DIR}/boot/firmware/ ${ROOTFS_DIR}/boot/firmware/

	mount --mkdir ${STAGE_WORK_DIR}/data.ext4 ${ROOTFS_DIR}/data

	./AB/fs-finalise.sh $slot

	unmount ${ROOTFS_DIR}/data
	unmount ${ROOTFS_DIR}/boot/firmware
	unmount ${ROOTFS_DIR}
done


cat files/genimage-image.template | sed \
	-e "s|<STAGE_WORK_DIR>|$STAGE_WORK_DIR|g" \
	-e "s|<IMG_NAME>|$IMG_NAME|g" \
	-e "s|<IMG_SUFFIX>|$IMG_SUFFIX|g" \
	-e "s|<IMG_FILENAME>|$IMG_FILENAME|g" \
	-e "s|<ARCHIVE_FILENAME>|$ARCHIVE_FILENAME|g" \
	> ${STAGE_WORK_DIR}/config/image.cfg


rm -rf ${STAGE_WORK_DIR}/genimage.tmp
genimage \
	--rootpath ${ROOTPATH_TMP} \
	--tmppath ${STAGE_WORK_DIR}/genimage.tmp \
	--inputpath ${STAGE_WORK_DIR}   \
	--outputpath ${STAGE_WORK_DIR} \
	--config ${STAGE_WORK_DIR}/config/image.cfg
