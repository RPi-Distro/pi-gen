#!/bin/bash -e

on_chroot <<CHEOF

	# Add packagecloud wlanpi/main repository
	curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | sudo bash
	
	# Add packagecloud wlanpi/dev repository
	curl -s https://packagecloud.io/install/repositories/wlanpi/dev/script.deb.sh | sudo bash	

	apt-get update

	# Disable FPMS as it will conflifct with wlanpi-hwtest
	sudo systemctl disable wlanpi-fpms

CHEOF
