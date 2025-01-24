#!/bin/bash -e

if [[ "${ENABLE_CLOUD_INIT}" == "0" ]]; then
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B4
	EOF
else
	on_chroot <<- EOF
		raspi-config nonint do_boot_behaviour B4
	EOF
fi