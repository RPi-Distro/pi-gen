#!/bin/bash -e

on_chroot << EOF
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
EOF
