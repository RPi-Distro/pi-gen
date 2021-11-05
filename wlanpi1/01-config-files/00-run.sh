#!/bin/bash -e

# Copy default avahi ssh.service
[[ -f "${ROOTFS_DIR}"/usr/share/doc/avahi-daemon/examples/ssh.service ]] && \
cp "${ROOTFS_DIR}"/usr/share/doc/avahi-daemon/examples/ssh.service "${ROOTFS_DIR}"/etc/avahi/services/

# Create WLAN Pi MOTD
copy_overlay /etc/update-motd.d/00-wlanpi-motd -o root -g root -m 755

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

	# Enable Dynamic Voltage and Frequency Scaling
	echo >> /boot/config.txt
	echo "# Enable Dynamic Voltage and Frequency Scaling" >> /boot/config.txt
	echo "dvfs=1" >> /boot/config.txt

	# Enable built-in RJ-45 console port
	echo >> /boot/config.txt
	echo "# Enable built-in RJ-45 console port" >> /boot/config.txt
	echo "dtoverlay=uart3" >> /boot/config.txt

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
	rm /etc/motd
	
	# Remove Cockpit MOTD
	rm /etc/motd.d/cockpit
	
	# Create a new stats command which displays MOTD on demand
	ln -fs /etc/update-motd.d/00-wlanpi-motd /usr/local/bin/stats
	
	#Auto-start systemd-networkd used by Bluetooth pan0
	systemctl enable systemd-networkd
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

# Copy config file: RF Central Regulatory Domain Agent
copy_overlay /etc/default/crda -o root -g root -m 644

# Copy state file: WLAN Pi Mode
copy_overlay /etc/wlanpi-state -o root -g root -m 644

# Enable kernel modules for USB OTG
copy_overlay /etc/modules-load.d/rndis.conf -o root -g root -m 644
