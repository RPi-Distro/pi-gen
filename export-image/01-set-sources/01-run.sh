#!/bin/bash -e

on_chroot sh -e - <<EOF
apt-get update
apt-get -y dist-upgrade
apt-get clean
EOF
