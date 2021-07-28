#!/bin/bash -e

####################
# Install Profiler and speedtest
####################

on_chroot <<CHEOF
	# Set pipx variables for the remainder of the script
	export PIPX_HOME=/opt/wlanpi/pipx
	export PIPX_BIN_DIR=/opt/wlanpi/pipx/bin
	
	# Install speedtest
	pipx install speedtest-cli
CHEOF
