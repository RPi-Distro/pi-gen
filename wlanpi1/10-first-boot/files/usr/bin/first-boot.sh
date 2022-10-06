#!/bin/bash

ufw enable

systemctl disable wlanpi-first-boot

ip link set eth0 mtu 1500
