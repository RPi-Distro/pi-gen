#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	bootstrap ${RELEASE} "${ROOTFS_DIR}" "${BOOTSTRAP_URL}"
fi
