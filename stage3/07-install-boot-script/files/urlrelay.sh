#!/bin/bash

# The web UI on this device can be accessed from any web browser on same local network.
# However the IP address may not be known, it is assigned by DHCP.
# Solution is to save the url with the urlrelay.com service, which uses source IP and nodeId as keys.
# Then the url can be easily retrieved from any web browser on same local network.
#
# When user goes to urlrelay.com/go, urlrelay service will redirect to the saved URL.
# 
# Node ID is required if there are multiple device on same local network registered with urlrelay.com
# In that case use:   urlrelay.com/go?id=<node-id>
#
# Source IP is the external IP address of your router, so the saved URL is only accessible from behind the same router.
# nodeId can be anything, it is required when multiple devices are behind the same router.
#
# The default URL is for use with noVNC running on the same device.
# HTTP is used to avoid needing to install a certificate for the UI browser.
# If HTTPS is used, the browser will require a secure websocket (wss://),
# which requires a CA certificate to be installed on the device running the browser.
#
# Parameters will be sourced from /etc/urlrelay/urlrelay.conf it it exists:
#
#  NODE_ID                Node ID of this device (default: 1)
#
#  URL                    Full url, may contain shell variable ${MY_IP} for local IP
#                         default:  http://${MY_IP}:6080${URL_ARGS}
#
#  URL_ARGS               query string, i.e. "/?password=xyz123"  (default: "")
#
#  REQUIRE_ID             0: (default) don't require node ID if this is the only device on this local network
#                         1: require node ID even if this is the only device on this local network

# wait until we have a network connection
while [ ! "$(ping -c 1 google.com)" ]; do
  sleep 10
done

# get route info for interface used to get to internet
IP_ROUTE=`ip -o route get to 8.8.8.8`
# extract the source IP and device name
MY_IP=`echo "$IP_ROUTE" | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
MY_INTF=`echo "$IP_ROUTE" | sed -n 's/.*dev \([a-zA-Z0-9:-]\+\).*/\1/p'`
# lookup the MAC address
MACADDR=`cat /sys/class/net/$MY_INTF/address`

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
