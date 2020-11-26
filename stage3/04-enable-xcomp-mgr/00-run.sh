#!/bin/bash -e

on_chroot << EOF
	raspi-config nonint do_xcompmgr 0
EOF
