#!/bin/bash -e

# Install Docker using default installation script
# and perform post-install steps to not require
# sudo for docker commands
echo "Installing docker..."
on_chroot << EOF
curl -sSL get.docker.com | sh
usermod -aG docker ${FIRST_USER_NAME}
EOF

# Install docker-compose
echo "Installing docker-compose"
on_chroot << EOF
pip3 install docker-compose

# Ensure it's in PATH
ln -sfn /home/${FIRST_USER_NAME}/.local/bin/docker-compose /usr/bin/docker-compose
EOF
