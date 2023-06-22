#!/bin/bash -e

echo "## Creating STH user"

on_chroot << EOF
adduser sth --system --home /usr/lib/sth
addgroup sth --system

# Add them to groups
usermod -aG sudo sth
usermod -aG gpio sth

# Create a sth-owned folder to put the app in
# You call this whatever you like, probably the name of your application
mkdir -p /usr/lib/sth
EOF
