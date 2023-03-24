#!/bin/bash -e

if [ "${PIGEN_RUNNING_INSIDE_DOCKER}" != "1" ]; then
  if [ ! -x "${ROOTFS_DIR}/usr/bin/qemu-arm-static" ]; then
    cp /usr/bin/qemu-arm-static "${ROOTFS_DIR}/usr/bin/"
  fi
fi

if [ -e "${ROOTFS_DIR}/etc/ld.so.preload" ]; then
	mv "${ROOTFS_DIR}/etc/ld.so.preload" "${ROOTFS_DIR}/etc/ld.so.preload.disabled"
fi
