# Add i3 config file
mkdir -m 644 ${ROOTFS_DIR}/home/pi/.config/i3/
install -m 755 files/i3.conf ${ROOTFS_DIR}/home/pi/.config/i3/config
on_chroot << EOF
    chown -R pi:root /home/pi/.config/i3/
EOF

