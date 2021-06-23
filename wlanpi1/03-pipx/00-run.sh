#!/bin/bash -e

####################
# Setup pipx
####################

on_chroot <<CHEOF
	# Install a deterministic version of pipx
	python3 -m pip install pipx==0.15.4.0

	# Setting up Pipx in a global directory so all users in sudo group can access installed packages
	mkdir -p /opt/wlanpi/pipx/bin
	chown -R root:sudo /opt/wlanpi/pipx
	chmod -R g+rwx /opt/wlanpi/pipx

	cat <<-EOF >> /etc/environment
	PIPX_HOME=/opt/wlanpi/pipx
	PIPX_BIN_DIR=/opt/wlanpi/pipx/bin
	EOF

	# Set pipx variables for the remainder of the script
	export PIPX_HOME=/opt/wlanpi/pipx
	export PIPX_BIN_DIR=/opt/wlanpi/pipx/bin
CHEOF
