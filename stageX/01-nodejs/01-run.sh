#!/bin/bash -e

on_chroot << EOF
ln -sf "$(which nodejs)" /usr/bin/node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
EOF
