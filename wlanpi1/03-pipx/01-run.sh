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

	# Install profiler2 
	pipx install git+https://github.com/wlan-pi/profiler2.git@main#egg=profiler2
CHEOF

copy_overlay /lib/systemd/system/profiler.service -o root -g root -m 644
copy_overlay /etc/profiler2/config.ini -o root -g root -m 644
