#!/bin/bash -e

####################
# Install Profiler and speedtest
####################

copy_overlay /lib/systemd/system/profiler.service -o root -g root -m 644
copy_overlay /etc/profiler2/config.ini -o root -g root -m 644

on_chroot <<CHEOF
	# Install speedtest
	pipx install speedtest-cli

	# Install profiler2 
	pipx install git+https://github.com/wlan-pi/profiler2.git@main#egg=profiler2
CHEOF
