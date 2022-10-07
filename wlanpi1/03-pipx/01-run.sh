#!/bin/bash -e

############################################
# Install sivel's unofficial speedtest-cli #
############################################

on_chroot <<CHEOF
	# Set pipx variables for the remainder of the script
	export PIPX_HOME=/opt/wlanpi/pipx
	export PIPX_BIN_DIR=/opt/wlanpi/pipx/bin
	
	# Install speedtest
	pipx install speedtest-cli
	# Remove speedtest symlink (speedtest-cli is still available) and free it up for the official Ookla's speedtest tool
	sudo unlink /opt/wlanpi/pipx/bin/speedtest
	sudo unlink /usr/local/bin/speedtest
CHEOF
