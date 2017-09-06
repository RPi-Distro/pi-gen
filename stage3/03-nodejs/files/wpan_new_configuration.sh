#!/bin/sh

CONFIG_ROOT=/home/pi/.node-red/scripts

# Insecure /dev/urandom can be used xpanid and name
XPANID=`head -c 64 /dev/urandom | sha256sum -b | head -c 16`
NETWORK_NAME=RPi-`head -c 64 /dev/urandom | sha256sum -b | head -c 4`

echo -n $XPANID > $CONFIG_ROOT/wpan_network_xpanid
echo -n $NETWORK_NAME > $CONFIG_ROOT/wpan_network_name

# Secure /dev/random MUST be used when generating network key
head -c 64 /dev/random | sha256sum -b | head -c 32 > $CONFIG_ROOT/wpan_network_key
