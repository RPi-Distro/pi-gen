#!/bin/bash -e

NODE_VERSION=18

echo "Installing node.js $NODE_VERSION"

on_chroot << EOF
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    sudo apt-get install -y nodejs jq python3-pip python-is-python3
EOF
