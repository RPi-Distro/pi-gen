#!/bin/bash

# The VNC interface on this device can be accessed from any web browser on same local network.
# However the IP address may not be known, it is assigned by DHCP.
# Solution is to save the url with the urlrelay.com service, which uses source IP and nodeId as keys.
# Then the url can be retrieved from any web browser on same local network.
#
# When user goes to https://urlrelay.com/go?<node-id> , urlrelay service will redirect to the saved URL.
#
# Source IP is the external IP address of your router, so the saved URL is only
# accessible from behind the same router.
# nodeId can be anything, it is required when multiple devices are behind the same router.
#
# The default URL is for use with noVNC running on the same device.
# HTTP is used to avoid needing to install a certificate for the UI browser.
# If HTTPS is used, the browser will require a secure websocket (wss://),
# which requires a CA certificate to be installed on the device running the browser.
#

while [ ! "$(ping -c 1 google.com)" ]; do
    sleep 10
done

# MY_IP=`ip -o -4 a | awk '$2 == "eth0" { gsub(/\/.*/, "", $4); print $4 }'`
MY_IP=`ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | grep -v 169.254. | awk '{ print $2 }' | cut -f2 -d: | head -n 1`
MACADDR=`cat /sys/class/net/eth0/address`

if [ -f /etc/urlrelay/urlrelay.conf ]; then
    source /etc/urlrelay/urlrelay.conf
fi

[[ -z "$NODE_ID" ]] && NODE_ID=1
[[ -z "$REQUIRE_ID" ]] && REQUIRE_ID=0
[[ -z "$URL" ]] && URL="http://${MY_IP}:6080${URL_ARGS}"

PYTHON_VERSION=`python --version 2>&1`

while [ 1 ]
do
  if [[ "$PYTHON_VERSION" =~ ^Python.2.*$ ]]; then
    # python2:
    ENC_URL=$(python -c "import urllib, sys; print urllib.quote(sys.argv[1])" "$URL")
  else
    # python3
    ENC_URL=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$URL")
  fi
  curl -s "https://urlrelay.com/set?id=${NODE_ID}&url=${ENC_URL}&requireId=${REQUIRE_ID}&macaddr=${MACADDR}"
  # re-register once per day
  sleep 1d
done
