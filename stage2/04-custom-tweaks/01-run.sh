#!/bin/bash -e

# Install Docker using default installation script
# and perform post-install steps to not require
# sudo for docker commands
echo "Installing docker..."
on_chroot << EOF
curl -sSL get.docker.com | sh
usermod -aG docker ${FIRST_USER_NAME}
EOF