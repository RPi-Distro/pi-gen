# Do mixxx stuff like copy the udev rules and config file
install -m 644 files/mixxx.cfg ${ROOTFS_DIR}/home/pi/.mixxx/mixxx.cfg
install -m 440 files/udev.mixxx ${ROOTFS_DIR}/etc/udev/rules.d/69-mixxx-usb-uaccess.rules
on_chroot << EOF
    chown -R pi:root /home/pi/.mixxx
EOF


# USB Mount
mkdir -m 644 ${ROOTFS_DIR}/etc/systemd/system/systemd-udevd.service.d
install -m 644 files/00-usbmountflags.conf ${ROOTFS_DIR}/etc/systemd/system/systemd-udevd.service.d/00-usbmountflags.conf
