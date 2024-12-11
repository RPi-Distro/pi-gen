#!/bin/bash -e

# Newer versions of raspberrypi-sys-mods set rfkill.default_state=0 to prevent
# radiating on 5GHz bands until the WLAN regulatory domain is set.
# Unfortunately, this also blocks bluetooth, so we whitelist the known
# on-board BT adapters here.

mkdir -p "${ROOTFS_DIR}/var/lib/systemd/rfkill/"
#           5                 miniuart 4      miniuart Zero   miniuart other  other
for addr in 107d50c000.serial 3f215040.serial 20215040.serial fe215040.serial soc; do
	echo 0 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-${addr}:bluetooth"
done

if [ -v WPA_COUNTRY ]; then
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_wifi_country "${WPA_COUNTRY}"
	EOF
elif [ -d "${ROOTFS_DIR}/var/lib/NetworkManager" ]; then
	# NetworkManager unblocks all WLAN devices by default. Prevent that:
	cat > "${ROOTFS_DIR}/var/lib/NetworkManager/NetworkManager.state" <<- EOF
		[main]
		WirelessEnabled=false
	EOF
fi
