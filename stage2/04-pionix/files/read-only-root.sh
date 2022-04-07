#!/bin/bash
# change root to read only, this should be run after the first boot as some services require write access on first boot.
sed -i '3s/rw/ro/' /etc/fstab
systemctl disable read-only-root.service
mount -o remount,ro /
