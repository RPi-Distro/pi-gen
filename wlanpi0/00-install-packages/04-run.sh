#!/bin/bash -e

on_chroot <<CHEOF
	# Add Kismet repository
	wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | apt-key add -
	echo 'deb https://www.kismetwireless.net/repos/apt/release/bullseye bullseye main' | tee /etc/apt/sources.list.d/kismet.list
	
	# Add packagecloud wlanpi/main repository
	curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | sudo bash
	
	# Add packagecloud wlanpi/dev repository
	curl -s https://packagecloud.io/install/repositories/wlanpi/dev/script.deb.sh | sudo bash	

	# Add Bullseye Backports repository
	echo 'deb http://deb.debian.org/debian bullseye-backports main' | tee /etc/apt/sources.list.d/bullseye-backports.list
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138

	apt-get update
CHEOF
