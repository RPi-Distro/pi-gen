#!/bin/bash -e

####################
# Setup RNDIS
####################

# Copy interfaces overlay: rndis.conf
copy_overlay /etc/network/interfaces.d/rndis.conf -o root -g root -m 644

# Copy overlay: isc-dhcp-server
copy_overlay /etc/default/isc-dhcp-server -o root -g root -m 644

on_chroot <<CHEOF
	echo "options g_ether host_addr=5e:a4:f0:3e:31:d3 use_eem=0" > /etc/modprobe.d/g_ether.conf

	# Configure DHCP: dhcpd.conf
	cat <<-EOF >> /etc/dhcp/dhcpd.conf

# usb0 DHCP scope
subnet 169.254.42.0 netmask 255.255.255.224 {
	interface usb0;
	range 169.254.42.2 169.254.42.30;
	option domain-name-servers wlanpi.local;
	option domain-name "wlanpi.local";
	option broadcast-address 169.254.42.31;
	default-lease-time 86400;
	max-lease-time 86400;
}
EOF

CHEOF
