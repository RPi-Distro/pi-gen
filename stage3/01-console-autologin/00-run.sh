#!/bin/bash -e

on_chroot << EOF
	TERM=linux SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B2
EOF
