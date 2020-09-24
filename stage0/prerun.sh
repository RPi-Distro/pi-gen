#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	bootstrap ${RELEASE} "${ROOTFS_DIR}" "${REPOSITORY_URL}"
fi
