#!/bin/sh

XPANID=`cat /home/pi/.node-red/scripts/wpan_network_xpanid`
NETWORK_KEY=`cat /home/pi/.node-red/scripts/wpan_network_key`
NETWORK_NAME=`cat /home/pi/.node-red/scripts/wpan_network_name`

wpanctl setprop Network:XPANID $XPANID
wpanctl setprop Network:Key $NETWORK_KEY
wpanctl form -c 11 $NETWORK_NAME
