#!/bin/bash -e

if [[ "${DISABLE_FIRST_BOOT_USER_RENAME}" == "0" ]]; then
	# with cloud-init enabled this will throw an error 
	# when run more than once, as the service will be deleted
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" rename-user -f -s
	EOF

	# delete userconfig service as cloud-init will take care of launching it
	rm -f "${ROOTFS_DIR}/lib/systemd/system/userconfig.service"
else
	rm -f "${ROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop"
	
	# if cloud-init enabled disable setup wizard launch completely
	if [[ "${ENABLE_CLOUD_INIT}" == "1" ]]; then
		on_chroot <<- EOF
			touch /var/lib/userconf-pi/deactivate
		EOF
	fi
fi
