#!/bin/bash

CHANNEL="unstable"

METAS="/etc/update.meta"
HWIDS=`jq -r ".update.hwid" $METAS`
VERSIONS=`jq -r ".update.version" $METAS`

# temporary download location
DOWNLOADDIR="/mnt/user_data/update"
mkdir -p "/mnt/user_data/update"

curl "https://pionix-update.de/$HWIDS/$CHANNEL/current.meta?current_ver=$VERSIONS" --output $DOWNLOADDIR/update.meta
RET=$?
if [ $RET -eq 0 ]; then
  METAU=$DOWNLOADDIR/update.meta
else
  echo "Error: Download failed for https://pionix-update.de/$HWIDS/$CHANNEL/current.meta?current_ver=$VERSIONS"
  exit 5
fi

HWIDU=`jq -r ".update.hwid" $METAU`
VERSIONU=`jq -r ".update.version" $METAU`
DOWNLOADURI=`jq -r ".update.download_uri" $METAU`

rm $METAU

# check if the update is really for our hw
if [ $HWIDU == $HWIDS ]; then
  echo Update found for our hardware $HWIDS

  # check if version is higher then ours
  if [ $VERSIONU -gt $VERSIONS ]; then
    echo "New version $VERSIONU (currently installed $VERSIONS)"
    # Fetch update from server
    curl $DOWNLOADURI --output $DOWNLOADDIR/update.raucb
    RET=$?
    if [ $RET -eq 0 ]; then
      echo "Download successful. Installing and rebooting..."
      install_update $DOWNLOADDIR/update.raucb --reboot-delete
    else
      echo "Error: File download failed of URI: $DOWNLOADURI"
      exit 4
    fi
  else
    echo "Error: Update is not newer: $VERSIONU (currently installed $VERSIONS)"
    exit 3
  fi
else
  echo Error: Update is for $HWIDU, but our system is $HWIDS.
  exit 2
fi

