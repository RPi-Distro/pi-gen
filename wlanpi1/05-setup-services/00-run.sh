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
	systemctl enable networkinfo
	systemctl enable cockpit.socket
CHEOF
