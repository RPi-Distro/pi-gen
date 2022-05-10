#!/bin/bash -e

install -v -m 644 files/autostart "${ROOTFS_DIR}/etc/xdg/lxsession/LXDE-pi/autostart"

install -v -m 655 files/coe-client-ui "${ROOTFS_DIR}/opt/coe-client-ui"
install -v -m 644 files/coe-client.conf "${ROOTFS_DIR}/etc/coe-client.conf"

install -v -m 644 files/eGTouchL.ini "${ROOTFS_DIR}/etc/eGTouchL.ini"
install -v -m 655 files/eGTouchD "${ROOTFS_DIR}/opt/eGTouchD"
install -v -m 655 files/eCalib "${ROOTFS_DIR}/opt/eCalib"
install -v -m 777 files/eGTouchD.service "${ROOTFS_DIR}/etc/systemd/system/eGTouchD.service"
install -v -m 777 files/81-egalax-touchscreen.rules "${ROOTFS_DIR}/etc/udev/rules.d/81-egalax-touchscreen.rules"
