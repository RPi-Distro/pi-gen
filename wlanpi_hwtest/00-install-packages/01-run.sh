#!/bin/bash -e

on_chroot <<CHEOF
	# Remove FPMS package that conflicts with wlanpi_hwtest
	apt remove wlanpi-fpms
CHEOF
