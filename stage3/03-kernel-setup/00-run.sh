# Add threadirqs kernel command line argument
on_chroot << EOF
    sed -i 's/$/ threadirqs/' /boot/cmdline.txt
EOF

# Use the performance governor instead of ondemand which is default
install -m 755 files/raspi-performance-config.sh ${ROOTFS_DIR}/etc/init.d/raspi-config
