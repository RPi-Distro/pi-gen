install -v -o root -m 644 -t "${ROOTFS_DIR}/etc/systemd/system" files/usb-gadget.service
install -v -o root -m 600 -t "${ROOTFS_DIR}/etc/NetworkManager/system-connections" files/usb0-link-local files/usb1-link-local
install -v -o root -m 644 -t "${ROOTFS_DIR}/etc/udev/rules.d" files/90-manage-usb0-gadget.rules files/90-manage-usb1-gadget.rules
install -v -o root -m 755 -t "${ROOTFS_DIR}/usr/local/sbin" files/usb-gadget-ctl.sh
