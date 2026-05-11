#!/bin/bash -e

# Install APPLaunch + configure boot for CardputerZero
on_chroot << 'CHROOT'
set -e

# Download latest APPLaunch deb from public release
DEB_URL=$(curl -s https://api.github.com/repos/dianjixz/M5CardputerZero-UserDemo/releases \
    | grep -o 'https://github.com/[^"]*applaunch[^"]*_arm64\.deb' | head -1)

if [ -z "$DEB_URL" ]; then
    echo "ERROR: Could not find APPLaunch deb URL"
    exit 1
fi

echo "Downloading APPLaunch from: $DEB_URL"
curl -fsSL -o /tmp/applaunch.deb -L "$DEB_URL"
dpkg -i /tmp/applaunch.deb
rm -f /tmp/applaunch.deb

# Enable APPLaunch service
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
