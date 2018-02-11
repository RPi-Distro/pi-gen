#!/bin/sh -e

#
# This file belongs in /usr/lib/dhcpcd5/dhcpcd how you get it there is up to you
#

DHCPCD=/sbin/dhcpcd
INTERFACES=/etc/network/interfaces
REGEX="^[[:space:]]*iface[[:space:]](*.*)[[:space:]]*inet[[:space:]]*(dhcp|static)"
EXCLUDES=""

if grep -q -E $REGEX $INTERFACES; then
        #echo "Not running dhcpcd because $INTERFACES"
        #echo "defines some interfaces that will use a"
        #echo "DHCP client or static address"
        #exit 6
        for iface in `grep -E $REGEX $INTERFACES | cut -f2 -d" "`
        do
                if [[ $EXCLUDES != "" ]]; then
                        EXCLUDES="${EXCLUDES}|${iface}"
                else
                        EXCLUDES="${iface}"
                fi
        done
        EXCLUDES="(${EXCLUDES})"
fi

exec $DHCPCD -Z $EXCLUDES $@
