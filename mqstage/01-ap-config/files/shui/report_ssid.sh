#!/bin/bash

connection=`nmcli -t -f NAME con | head -n 1`

./hat_text.sh "$connection"

if [ "$connection" = "WiFiAP" ]; then
  ./hat_text.sh "$(nmcli connection show "WiFiAP" | grep "\.ssid:" | awk '{print $2 " " $3}')"
fi
./hat_text.sh "$(hostname -I | awk '{print $1}')"
