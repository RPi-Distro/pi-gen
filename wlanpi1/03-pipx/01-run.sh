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

	# Install profiler
	pipx install git+https://github.com/wlan-pi/profiler.git@main#egg=profiler
CHEOF

copy_overlay /lib/systemd/system/wlanpi-profiler.service -o root -g root -m 644
copy_overlay /etc/wlanpi-profiler/config.ini -o root -g root -m 644
