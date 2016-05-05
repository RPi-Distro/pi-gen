#!/bin/bash -e

if [ -e ${ROOTFS_DIR}/etc/ld.so.preload ]; then
	mv ${ROOTFS_DIR}/etc/ld.so.preload ${ROOTFS_DIR}/etc/ld.so.preload.disabled
fi

if [ ! -e ${ROOTFS_DIR}/usr/sbin/policy-rc.d ]; then
	install -m 744 files/policy-rc.d ${ROOTFS_DIR}/usr/sbin/
fi

if [ ! -x ${ROOTFS_DIR}/usr/bin/qemu-arm-static ]; then
	cp /usr/bin/qemu-arm-static ${ROOTFS_DIR}/usr/bin/
fi
