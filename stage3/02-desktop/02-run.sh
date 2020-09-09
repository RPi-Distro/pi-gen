# Add i3 config file
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.config/i3/
install -m 755 files/i3.conf ${ROOTFS_DIR}/home/pi/.config/i3/config
on_chroot << EOF
    chown -R pi:root /home/pi/.config/
    chmod -R 755 /home/pi/.config/
EOF
