#!/bin/bash -e

if [ "${ENABLE_CLOUD_INIT}" != "1" ]; then
	log "Skipping cloud-init stage"
	exit 0
fi

install -v -D -m 644 -t "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/" files/99_raspberry-pi.cfg

# some preseeding without any runtime effect yet
# install meta-data file for NoCloud data-source to work
#install -v -m 755 files/meta-data "${ROOTFS_DIR}/boot/firmware/meta-data"
#install -v -m 755 files/user-data "${ROOTFS_DIR}/boot/firmware/user-data"
#install -v -m 755 files/network-config "${ROOTFS_DIR}/boot/firmware/network-config" 

# setup default netplan config which will instruct netplan to pass control over to network-manager
# at boot time. This will make NetworkManager manage all devices and by default. 
# Any Ethernet device will come up with DHCP, once carrier is detected
install -v -D -m 600 -t "${ROOTFS_DIR}/lib/netplan/" files/00-network-manager-all.yaml

if [ -n "${FIRST_USER_NAME}" ]; then
  # set the default user name to the one provided via FIRST_USER_NAME
  # this will make cloud-init create the user with that name instead of 'pi'
  sed -i "s/name: pi/name: ${FIRST_USER_NAME}/" "${ROOTFS_DIR}/etc/cloud/cloud.cfg"
else
  # remove the users:\n - default section from cloud.cfg
  sed -i "/^users:/,/^- default/d" "${ROOTFS_DIR}/etc/cloud/cloud.cfg"
fi
