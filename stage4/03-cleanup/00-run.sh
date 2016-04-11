#!/bin/bash -e

on_chroot sh -e - <<EOF
apt-get clean
EOF
