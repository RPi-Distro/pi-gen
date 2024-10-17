#!/bin/bash -e

if [ "${ENABLE_CLOUD_INIT}" != "1" ]; then
	log "Skipping cloud-init stage"
	exit 0
fi

install -v -D -m 644 -t "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/" files/99_raspberry-pi.cfg

# install meta-data file for NoCloud data-source to work
install -v -m 755 files/meta-data "${ROOTFS_DIR}/boot/firmware/meta-data"
install -v -m 755 files/user-data "${ROOTFS_DIR}/boot/firmware/user-data"
install -v -m 755 files/network-config "${ROOTFS_DIR}/boot/firmware/network-config"

# setup default netplan config which will instruct netplan to pass control over to network-manager
# at boot time. This will make NetworkManager manage all devices and by default. 
# Any Ethernet device will come up with DHCP, once carrier is detected
install -v -D -m 600 -t "${ROOTFS_DIR}/usr/lib/netplan/" files/00-network-manager-all.yaml

# still does not solve the conflict, maybe some kind of race cond.
# make sure config stage is run before userconfig service
#sed -i '/^\[Unit\]/a Before=userconfig.service' "${ROOTFS_DIR}/lib/systemd/system/cloud-config.service"

install -v -m 755 files/cloud-init-custom.deb "${ROOTFS_DIR}/tmp/cloud-init.deb"

# remove cloud-init if already installed for rebuild support while working with custom deb
on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" dpkg -i /tmp/cloud-init.deb || true
	SUDO_USER="${FIRST_USER_NAME}" apt-get install -f -y
EOF

rm -f "${ROOTFS_DIR}/tmp/cloud-init.deb"

# userconfig service is deleted in export-image/01-user-rename stage
