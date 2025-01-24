#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.1.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

# if cloud-init disabled
if [[ "${ENABLE_CLOUD_INIT}" == "0" ]]; then

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_net_names 1
EOF

else

on_chroot << EOF
        raspi-config nonint do_net_names 1
EOF

fi
