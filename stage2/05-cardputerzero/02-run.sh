#!/bin/bash -e

# Download APPLaunch deb outside chroot (has GitHub token, avoids rate limit)
DEB_URL=$(curl -sH "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/CardputerZero/M5CardputerZero-Launcher/releases \
    | grep -o 'https://github.com/[^"]*applaunch[^"]*_arm64\.deb' | head -1)

if [ -z "$DEB_URL" ]; then
    echo "ERROR: Could not find APPLaunch deb URL"
    exit 1
fi

echo "Downloading APPLaunch from: $DEB_URL"
curl -fsSL -o "${ROOTFS_DIR}/tmp/applaunch.deb" -L "$DEB_URL"

# Install APPLaunch + configure boot for CardputerZero
on_chroot << 'CHROOT'
set -e
dpkg -i /tmp/applaunch.deb
rm -f /tmp/applaunch.deb
systemctl enable APPLaunch.service
CHROOT

# Append CardputerZero config to config.txt
cat >> "${ROOTFS_DIR}/boot/firmware/config.txt" << 'EOF'

# --- CardputerZero ---
dtparam=i2c_arm=on
dtparam=spi=on
dtoverlay=cardputerzero-overlay
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=320 170 60 1 0 0 0
EOF

# Append cmdline.txt parameters
sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles cfg80211.ieee80211_regdom=AE/' \
    "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

# Module load config
cat > "${ROOTFS_DIR}/etc/modules-load.d/cardputerzero.conf" << 'EOF'
i2c-dev
EOF

# Modprobe configs
cat > "${ROOTFS_DIR}/etc/modprobe.d/blacklist-8192cu.conf" << 'EOF'
blacklist 8192cu
EOF

cat > "${ROOTFS_DIR}/etc/modprobe.d/rfkill_default.conf" << 'EOF'
options rfkill default_state=0
EOF

# Splash restore service: after Linux boots, swap kernel files back
# so next cold boot shows Circle splash again
cat > "${ROOTFS_DIR}/etc/systemd/system/splash-restore.service" << 'EOF'
[Unit]
Description=Restore Circle splash kernel after boot
DefaultDependencies=no
After=boot-firmware.mount
Before=sysinit.target
ConditionPathExists=/boot/firmware/kernel8-splash.bak

[Service]
Type=oneshot
ExecStart=/bin/mv /boot/firmware/kernel8.img /boot/firmware/kernel8.img.linux
ExecStart=/bin/mv /boot/firmware/kernel8-splash.bak /boot/firmware/kernel8.img

[Install]
WantedBy=sysinit.target
EOF

on_chroot << 'CHROOT'
systemctl enable splash-restore.service
CHROOT

# Install Circle splash binary and rename Linux kernel
# Circle splash shows logo then renames files and reboots into Linux
cp "${ROOTFS_DIR}/boot/firmware/kernel8.img" "${ROOTFS_DIR}/boot/firmware/kernel8.img.linux"
install -m 755 files/kernel8-splash.img "${ROOTFS_DIR}/boot/firmware/kernel8.img"
