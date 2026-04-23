#!/bin/bash -e

on_chroot <<- EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_vnc 1
	apt remove -y vlc
EOF

# Add Home folder shortcut to desktop
mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop"
cat > "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/home.desktop" <<- EOF
	[Desktop Entry]
	Name=Home
	Icon=folder-home
	Type=Directory
	URL=file:///home/${FIRST_USER_NAME}
EOF
chmod 755 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/home.desktop"
