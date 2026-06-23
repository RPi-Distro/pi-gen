#!/bin/bash -e

# Download APPLaunch deb outside chroot (can use GitHub token to avoid rate limits)
AUTH_ARGS=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
    AUTH_ARGS=(-H "Authorization: token ${GITHUB_TOKEN}")
fi

DEB_URL=$(curl -fsSL "${AUTH_ARGS[@]}" \
    https://api.github.com/repos/CardputerZero/launcher/releases \
    | grep -o 'https://github.com/[^"]*applaunch[^"]*_arm64\.deb' | head -1)

UBOOT_URL="${UBOOT_FIRMWARE_URL:-https://github.com/CardputerZero/u-boot/releases/latest/download/uboot-firmware-m5stack.tar.gz}"


if [ -z "$DEB_URL" ]; then
    echo "ERROR: Could not find APPLaunch deb URL"
    exit 1
fi

echo "Downloading APPLaunch from: $DEB_URL"
curl -fsSL -o "${ROOTFS_DIR}/tmp/applaunch.deb" -L "$DEB_URL"

echo "Downloading U-Boot firmware from: $UBOOT_URL"
curl -fsSL -o "${ROOTFS_DIR}/tmp/uboot-firmware.tar.gz" -L "$UBOOT_URL"
tar -xzf "${ROOTFS_DIR}/tmp/uboot-firmware.tar.gz" -C "${ROOTFS_DIR}/boot/firmware"

# Install APPLaunch normally so dpkg registers the package. Then adjust startup
# state directly in the rootfs; LaunchWizard controls first-boot APPLaunch start.
on_chroot << 'CHROOT'
set -e
dpkg -i /tmp/applaunch.deb
rm -f /tmp/applaunch.deb
CHROOT

if [ ! -x "${ROOTFS_DIR}/usr/share/APPLaunch/bin/LaunchWizard" ]; then
    echo "ERROR: LaunchWizard missing from installed APPLaunch package"
    exit 1
fi

install -d "${ROOTFS_DIR}/usr/lib/systemd/system"
cat > "${ROOTFS_DIR}/usr/lib/systemd/system/LaunchWizard.service" << 'EOF'
[Unit]
Description=LaunchWizard First Boot Setup
After=systemd-user-sessions.service plymouth-quit.service
Before=display-manager.service
Wants=graphical.target plymouth-quit.service

[Service]
Type=simple
ExecStartPre=-/usr/bin/plymouth quit
ExecStartPre=-/usr/bin/timeout 3 /usr/bin/plymouth --wait
ExecStart=/usr/share/APPLaunch/bin/LaunchWizard
WorkingDirectory=/usr/share/APPLaunch
Restart=on-failure
RestartSec=1
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

install -d "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants"
ln -sf /usr/lib/systemd/system/LaunchWizard.service \
    "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/LaunchWizard.service"

install -d "${ROOTFS_DIR}/usr/lib/systemd/user"
cat > "${ROOTFS_DIR}/usr/lib/systemd/user/APPLaunch.service" << 'EOF'
[Unit]
Description=APPLaunch Service
After=pipewire-pulse.service
Wants=pipewire-pulse.service

[Service]
ExecStart=/usr/share/APPLaunch/bin/M5CardputerZero-APPLaunch
WorkingDirectory=/usr/share/APPLaunch
Restart=always
RestartSec=1
StartLimitInterval=0

[Install]
WantedBy=default.target
EOF

rm -f "${ROOTFS_DIR}/etc/systemd/user/default.target.wants/APPLaunch.service"
rm -f "${ROOTFS_DIR}/home/pi/.config/systemd/user/default.target.wants/APPLaunch.service"
rm -f "${ROOTFS_DIR}/var/lib/systemd/linger/pi"

install -d "${ROOTFS_DIR}/etc/xdg/autostart"
cat > "${ROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Raspberry Pi First-Run Wizard
Exec=piwiz
StartupNotify=true
EOF

install -d "${ROOTFS_DIR}/etc/lightdm/lightdm.conf.d"
cat > "${ROOTFS_DIR}/etc/lightdm/lightdm.conf.d/99-cardputerzero-firstboot.conf" << 'EOF'
[Seat:*]
autologin-user=rpi-first-boot-wizard
autologin-session=rpd-labwc
EOF

# Install U-Boot firmware
sed -i '1i kernel=u-boot.bin' ${ROOTFS_DIR}/boot/firmware/config.txt



# Append cmdline.txt parameters
sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles fbcon=map:off cfg80211.ieee80211_regdom=AE/' \
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

# Persistent journal — retain logs across reboots for debugging
mkdir -p "${ROOTFS_DIR}/var/log/journal"
mkdir -p "${ROOTFS_DIR}/etc/systemd/journald.conf.d"
cat > "${ROOTFS_DIR}/etc/systemd/journald.conf.d/persist.conf" << 'EOF'
[Journal]
Storage=persistent
SystemMaxUse=50M
EOF

# Root partition resize on first boot (U-Boot skips initramfs so
# raspberrypi-sys-mods' resize_early never runs)
install -m 755 -d "${ROOTFS_DIR}/usr/lib/cardputerzero"
install -m 755 files/resize-root "${ROOTFS_DIR}/usr/lib/cardputerzero/resize-root"
install -m 644 files/cardputerzero-resize.service "${ROOTFS_DIR}/etc/systemd/system/cardputerzero-resize.service"

on_chroot << 'CHROOT'
systemctl enable cardputerzero-resize.service
CHROOT
