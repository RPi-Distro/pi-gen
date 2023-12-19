# Do mixxx stuff like copy the udev rules and config file
# mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.mixxx
# install -m 755 files/mixxx.cfg ${ROOTFS_DIR}/home/pi/.mixxx/mixxx.cfg
# on_chroot << EOF
#     chown -R pi:root /home/pi/.mixxx
#     chmod -R 755 /home/pi/.mixxx/
# EOF
# Commented out because Mixxx complains about lack of db if you do this

install -m 644 files/udev.mixxx ${ROOTFS_DIR}/etc/udev/rules.d/69-mixxx-usb-uaccess.rules


# USB Mount
mkdir -m 644 ${ROOTFS_DIR}/etc/systemd/system/systemd-udevd.service.d
install -m 644 files/00-usbmountflags.conf ${ROOTFS_DIR}/etc/systemd/system/systemd-udevd.service.d/00-usbmountflags.conf

on_chroot << EOF
    apt remove -y cups cups-browsed cups-daemon
EOF
