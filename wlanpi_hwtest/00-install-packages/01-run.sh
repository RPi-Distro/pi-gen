#!/bin/bash -e

on_chroot <<CHEOF

	# Disable FPMS as it will conflifct with wlanpi-hwtest
	sudo systemctl disable wlanpi-fpms

CHEOF
