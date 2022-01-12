#!/bin/bash -e

####################
# Setup RNDIS
####################

on_chroot <<CHEOF
	echo "options g_ether host_addr=5e:a4:f0:3e:31:d3 use_eem=0" > /etc/modprobe.d/g_ether.conf
CHEOF
