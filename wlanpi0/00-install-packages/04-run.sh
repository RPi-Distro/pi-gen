#!/bin/bash -e

on_chroot <<CHEOF
	# Add Kismet repository
	wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | apt-key add -
	echo 'deb https://www.kismetwireless.net/repos/apt/release/buster buster main' | tee /etc/apt/sources.list.d/kismet.list
	
	# Add packagecloud wlanpi/main repository
	curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | sudo bash

	apt-get update
CHEOF
