#!/bin/bash -e
on_chroot <<EOF
	apt-mark auto vlc-data
EOF
