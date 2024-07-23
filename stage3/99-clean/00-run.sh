#/bin/bash -e

on_chroot << EOF
	sudo apt-get purge -y --auto-remove gcc-7-base gcc-8-base gcc-9-base gcc-10-base tasksel
EOF