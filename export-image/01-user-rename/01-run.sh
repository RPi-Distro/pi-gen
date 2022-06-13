#!/bin/bash -e

if [ -z "${FORCE_USER_CREATION}" ]; then
	on_chroot << EOF
		SUDO_USER="${FIRST_USER_NAME}" rename-user -f -s
EOF
fi
