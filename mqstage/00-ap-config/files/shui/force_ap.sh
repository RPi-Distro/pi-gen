#!/bin/bash

connection=`nmcli -t -f NAME con | head -n 1`
echo "current connection is $connection"

if [ "$connection" != "WiFiAP" ]; then
	nmcli connection down "$connection"
	nmcli connection up "WiFiAP"
fi

./report_ssid.sh
