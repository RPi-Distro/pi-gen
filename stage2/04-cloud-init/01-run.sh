#!/bin/bash -e

if [ "${ENABLE_CLOUD_INIT}" != "1" ]; then
	log "Skipping cloud-init stage"
	exit 0
fi

# some preseeding without any runtime effect if not modified
# install meta-data file for NoCloud data-source to work
install -v -m 755 files/meta-data "${ROOTFS_DIR}/boot/firmware/meta-data"
install -v -m 755 files/user-data "${ROOTFS_DIR}/boot/firmware/user-data"
install -v -m 755 files/network-config "${ROOTFS_DIR}/boot/firmware/network-config" 
