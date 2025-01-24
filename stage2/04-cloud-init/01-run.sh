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

install -v -m 755 files/cloud-init-custom.deb "${ROOTFS_DIR}/tmp/cloud-init.deb"

# remove cloud-init if already installed for rebuild support while working with custom deb
# TODO: replace apt-get install -y /tmp/cloud-init.deb once patched cloud-init is in pub repos
on_chroot << EOF
	dpkg -i /tmp/cloud-init.deb || true
	apt-get install -f -y
EOF

rm -f "${ROOTFS_DIR}/tmp/cloud-init.deb"

# Generate cloud-init configuration based on build variables
log "Configuring default cloud-init settings"

cat << EOF > "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/99_default.cfg"
#cloud-config
keyboard:
  layout: ${KEYBOARD_LAYOUT:-"English (UK)"}
  keymap: "${KEYBOARD_KEYMAP:-gb}"
timezone: ${TIMEZONE_DEFAULT:-"Europe/London"}
users:
  - name: ${FIRST_USER_NAME:-"pi"}
    groups: [adm, dialout, cdrom, audio, users, sudo, video, games, plugdev, input, gpio, spi, i2c, netdev, render, lpadmin]
    lock_passwd: $( [ -n "${FIRST_USER_PASS}" ] && echo "true" || echo "false" )
    $( [ -n "${FIRST_USER_PASS}" ] || echo "plain_text_passwd: " )${FIRST_USER_PASS:-""}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
EOF

if [ -n "${PUBKEY_SSH_FIRST_USER}" ]; then
	printf "    ssh_authorized_keys:\n	  - ${PUBKEY_SSH_FIRST_USER}" >> "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/99_default.cfg"
fi

cat << EOF >> "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/99_default.cfg"
ssh_pwauth: $( [ "${PUBKEY_ONLY_SSH}" = "1" ] && echo "false" || echo "true")
EOF

log "Cloud-init configuration complete"
