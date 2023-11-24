
cp -r "${BASE_DIR}/../EffectiveRange/poc/wifiManager" "${ROOTFS_DIR}/tmp/wifiManager"

on_chroot << EOF

cd /tmp/wifiManager

# Package wifi-manager
dpkg-buildpackage -us -uc -b

# Install wifi-manager
apt-get install /tmp/wifi-manager_0.0.1_all.deb

EOF
