#!/bin/bash

# Enable firewall
ufw enable

# Remove speedtest symlink (speedtest-cli is still available) and free it up for the official Ookla's speedtest tool
unlink /opt/wlanpi/pipx/bin/speedtest
unlink /usr/local/bin/speedtest

# Don't autostart first boot service
systemctl disable wlanpi-first-boot
