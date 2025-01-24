#!/bin/bash -e

# TODO: remove
install -v -m 755 files/userconf-service "${ROOTFS_DIR}/usr/lib/userconf-pi/userconf-service"

if [[ "${DISABLE_FIRST_BOOT_USER_RENAME}" == "0" ]]; then
	if [[ "${ENABLE_CLOUD_INIT}" != "1" ]]; then
		on_chroot <<- EOF
			SUDO_USER="${FIRST_USER_NAME}" rename-user -f -s
		EOF
	else
		# Workaround for service not beeing started on first boot
		on_chroot <<- EOF
			systemctl enable userconfig.service
		EOF
	fi
else
	rm -f "${ROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop"
fi
