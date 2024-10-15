#!/bin/bash -e

# Copy default avahi ssh.service
[[ -f "${ROOTFS_DIR}"/usr/share/doc/avahi-daemon/examples/ssh.service ]] && \
cp "${ROOTFS_DIR}"/usr/share/doc/avahi-daemon/examples/ssh.service "${ROOTFS_DIR}"/etc/avahi/services/

on_chroot <<CHEOF
	# Set retry for dhclient
	if grep -q -E "^#?retry " /etc/dhcp/dhclient.conf; then
		sed -i 's/^#\?retry .*/retry 600;/' /etc/dhcp/dhclient.conf
	else
		echo "retry 600;" >> /etc/dhcp/dhclient.conf
	fi

	# Send hardware MAC address to DHCP server
	if grep -q -E "^#?send dhcp-client-identifier " /etc/dhcp/dhclient.conf; then
		sed -i 's/^#\?send dhcp-client-identifier .*/send dhcp-client-identifier = hardware;/' /etc/dhcp/dhclient.conf
	else
		echo "send dhcp-client-identifier = hardware;" >> /etc/dhcp/dhclient.conf
	fi

	# Setup: TFTP
	usermod -a -G tftp wlanpi
	chown -R tftp:tftp /srv/tftp
	chmod 775 /srv/tftp

	# Configure avahi txt record: id=wlanpi
	sed -i '/<port>/ a \ \ \ \ <txt-record>id=wlanpi</txt-record>' /etc/avahi/services/ssh.service

	# Change default systemd boot target: multi-user.target
	systemctl set-default multi-user.target

	# Configure arp_ignore: network/arp
	echo "net.ipv4.conf.eth0.arp_ignore = 1" >> /etc/sysctl.conf

	# Remove default Debian MOTD
	rm -f /etc/motd

	# Remove Cockpit MOTD
	rm -f /etc/motd.d/cockpit

	# Remove existing MOTD
	rm -f /etc/update-motd.d/10-uname

	#Auto-start systemd-networkd used by Bluetooth pan0 and usb0
	systemctl enable systemd-networkd

	# Fetch current version of the pci. ids file
	update-pciids

	# Prevent interfaces from being managed by dhcpcd which conflicts with systemd
	echo "denyinterfaces usb* pan*" | tee -a /etc/dhcpcd.conf

	# Install wireless-regdb which supports Wi-Fi 6E
	wget -O /tmp/wireless-regdb_2024.07.04-1_all.deb http://ftp.us.debian.org/debian/pool/main/w/wireless-regdb/wireless-regdb_2024.07.04-1_all.deb
	dpkg -i /tmp/wireless-regdb_2024.07.04-1_all.deb
	rm -f /tmp/wireless-regdb_2024.07.04-1_all.deb
	update-alternatives --set regulatory.db /lib/firmware/regulatory.db-upstream

	# Fix sntp permission error
	chmod o+w /var/lib/sntp/kod
	
	# Automatically reboot after 1 second if a kernel panic occurs
	echo "kernel.panic = 1" >> /etc/sysctl.conf
CHEOF

# Set WLAN Pi image version
copy_overlay /etc/wlanpi-release -o root -g root -m 644

# Setup TFTP
copy_overlay /etc/default/tftpd-hpa -o root -g root -m 644

# Add our custom sudoers file
copy_overlay /etc/sudoers.d/wlanpidump -o root -g root -m 440

# Add our pipx sudoers file for profiler
copy_overlay /etc/sudoers.d/pipx -o root -g root -m 440

# Copy ufw rules
copy_overlay /etc/ufw/user.rules -o root -g root -m 640

# Copy config file: avahi-daemon
copy_overlay /etc/avahi/avahi-daemon.conf -o root -g root -m 644

# Copy config file: wpa_supplicant.conf
copy_overlay /etc/wpa_supplicant/wpa_supplicant.conf -o root -g root -m 600

# Copy config file: network/interfaces
copy_overlay /etc/network/interfaces -o root -g root -m 644

# Copy config file: ifplugd
copy_overlay /etc/default/ifplugd -o root -g root -m 644

# Copy script: release-dhcp-lease
copy_overlay /etc/ifplugd/action.d/release-dhcp-lease -o root -g root -m 755

# Copy state file: WLAN Pi Mode
copy_overlay /etc/wlanpi-state -o root -g root -m 644

# Copy config file: systemd/network/usb0.network
copy_overlay /etc/systemd/network/usb0.network -o root -g root -m 644

# Enable kernel modules for USB OTG
copy_overlay /etc/modules-load.d/rndis.conf -o root -g root -m 644

# Copy USB1 network configuration
copy_overlay /etc/systemd/network/usb1.network -o root -g root -m 664

# Copy eth1 network configuration
copy_overlay /etc/systemd/network/eth1.network -o root -g root -m 664

# Copy config file: kismet_site.conf
copy_overlay /etc/kismet/kismet_site.conf -o root -g root -m 644

# Copy config file: kismet.service.d/override.conf
copy_overlay /etc/systemd/system/kismet.service.d/override.conf -o root -g root -m 644
