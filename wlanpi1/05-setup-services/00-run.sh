#!/bin/bash -e

####################
# General services
####################

# Setup service: iperf3
copy_overlay /lib/systemd/system/iperf3.service -o root -g root -m 644

# Setup service: iperf2
copy_overlay /lib/systemd/system/iperf2.service -o root -g root -m 644
copy_overlay /lib/systemd/system/iperf2-udp.service -o root -g root -m 644

on_chroot <<CHEOF
	systemctl enable iperf3
	systemctl enable cockpit.socket
	# ISC DHCP server is not used in Classic mode. Only Hotspot, Server and Wi-Fi Console modes rely on it today. The plan is to remove ISC DHCP server.
	systemctl disable isc-dhcp-server
CHEOF
