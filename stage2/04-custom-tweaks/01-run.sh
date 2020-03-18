#!/bin/bash -e

# Install Docker using default installation script
# and perform post-install steps to not require
# sudo for docker commands
echo "Installing docker..."
on_chroot << EOF
curl -sSL get.docker.com | sh
usermod -aG docker ${FIRST_USER_NAME}
EOF

# Ensure ${FIRST_USER_NAME} is set up for auto-login
echo "Setting up ${FIRST_USER_NAME} for auto-login"
on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B4
EOF