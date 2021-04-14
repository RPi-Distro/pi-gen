#!/bin/bash -e

# Setup first boot script
copy_overlay /usr/bin/first-boot.sh -o root -g root -m 755
copy_overlay /lib/systemd/system/wlanpi-first-boot.service -o root -g root -m 644

on_chroot <<CHEOF
	systemctl enable wlanpi-first-boot
CHEOF


