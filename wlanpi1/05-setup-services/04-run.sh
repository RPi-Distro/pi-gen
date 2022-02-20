#!/bin/bash -e

#######################
# Fix buffer on AX210 #
#######################

on_chroot <<CHEOF
	echo "options iwlwifi amsdu_size=3" > /etc/modprobe.d/iwlwifi.conf
CHEOF
