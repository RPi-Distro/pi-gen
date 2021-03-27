#!/bin/bash -e

on_chroot <<CHEOF
	usermod -aG sudo wlanpi
	usermod -aG www-data wlanpi
	usermod -aG kismet wlanpi

	# Include system binaries in wlanpi's PATH - avoid using sudo
	echo 'export PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"' >> /home/wlanpi/.profile
	# Include pipx bin location in wlanpi's PATH
	echo 'export PATH="$PATH:/opt/wlanpi/pipx/bin"' >> /home/wlanpi/.profile
CHEOF
