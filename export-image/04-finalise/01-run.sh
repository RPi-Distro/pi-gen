#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img"

on_chroot << EOF
/etc/init.d/fake-hwclock stop
hardlink -t /usr/share/doc
EOF

if [ -d ${ROOTFS_DIR}/home/pi/.config ]; then
	chmod 700 ${ROOTFS_DIR}/home/pi/.config
fi

rm -f ${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache
rm -f ${ROOTFS_DIR}/usr/sbin/policy-rc.d
rm -f ${ROOTFS_DIR}/usr/bin/qemu-arm-static
if [ -e ${ROOTFS_DIR}/etc/ld.so.preload.disabled ]; then
        mv ${ROOTFS_DIR}/etc/ld.so.preload.disabled ${ROOTFS_DIR}/etc/ld.so.preload
fi

rm -f ${ROOTFS_DIR}/etc/apt/sources.list~
rm -f ${ROOTFS_DIR}/etc/apt/trusted.gpg~

rm -f ${ROOTFS_DIR}/etc/passwd-
rm -f ${ROOTFS_DIR}/etc/group-
rm -f ${ROOTFS_DIR}/etc/shadow-
rm -f ${ROOTFS_DIR}/etc/gshadow-

rm -f ${ROOTFS_DIR}/var/cache/debconf/*-old
rm -f ${ROOTFS_DIR}/var/lib/dpkg/*-old

rm -f ${ROOTFS_DIR}/usr/share/icons/*/icon-theme.cache

rm -f ${ROOTFS_DIR}/var/lib/dbus/machine-id

true > ${ROOTFS_DIR}/etc/machine-id

ln -nsf /proc/mounts ${ROOTFS_DIR}/etc/mtab

for _FILE in $(find ${ROOTFS_DIR}/var/log/ -type f); do
	true > ${_FILE}
done

rm -f "${ROOTFS_DIR}/root/.vnc/private.key"

update_issue $(basename ${EXPORT_DIR})
install -m 644 ${ROOTFS_DIR}/etc/rpi-issue ${ROOTFS_DIR}/boot/issue.txt
install files/LICENSE.oracle ${ROOTFS_DIR}/boot/

ROOT_DEV=$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')

unmount ${ROOTFS_DIR}
zerofree -v ${ROOT_DEV}

unmount_image ${IMG_FILE}

mkdir -p ${DEPLOY_DIR}

rm -f ${DEPLOY_DIR}/image_${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.zip

echo zip ${DEPLOY_DIR}/image_${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.zip ${IMG_FILE}
pushd ${STAGE_WORK_DIR} > /dev/null
zip ${DEPLOY_DIR}/image_${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.zip $(basename ${IMG_FILE})
popd > /dev/null
