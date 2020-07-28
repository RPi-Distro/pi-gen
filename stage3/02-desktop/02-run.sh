# Add i3 config file
install -m 755 files/i3.conf ${ROOTFS_DIR}/home/pi/.config/i3
on_chroot << EOF
    chown -R pi:root /home/pi/.config/
EOF

