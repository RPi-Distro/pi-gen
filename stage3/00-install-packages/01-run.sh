#!/bin/bash -e

on_chroot << EOF
  systemctl unmask hostapd.service
  systemctl enable hostapd.service
  pip install flask waitress netifaces dbus-python PyGObject gpiozero
EOF
