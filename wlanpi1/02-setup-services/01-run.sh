#!/bin/bash -e

####################
# WiPerf
####################

on_chroot <<CHEOF
	# Install wiperf poller
	python3 -m pip install wiperf_poller
CHEOF
