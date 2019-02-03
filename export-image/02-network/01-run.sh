#!/bin/bash -e

on_chroot << EOF
rm -f /etc/resolv.conf
touch /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolve.conf /etc/resolv.conf
sed -i -e 's/\/run\//\/var\/run\//' /etc/systemd/system/dhcpcd5.service
mv /etc/dhcpcd.conf /boot/
chown root:root /boot/dhcpcd.conf
ln -s /boot/dhcpcd.conf /etc/dhcpcd.conf
EOF
