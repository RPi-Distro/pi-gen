#!/bin/bash

# try to use same device as Jack by looking at jackdrc.conf
# This can be overridden by setting JAMULUS_ALSA_DEVICE in jamulus_start.conf
if [ -f /etc/jackdrc.conf ]; then
  source /etc/jackdrc.conf
  regex="^hw:([0-9]),.*"
  if [[ "$DEVICE"  =~ $regex ]]; then
    JAMULUS_ALSA_DEVICE="card ${BASH_REMATCH[1]}"
  fi
fi

if [ -f ~/.config/Jamulus/jamulus_start.conf ]; then
  source ~/.config/Jamulus/jamulus_start.conf
fi

# if $JAMULUS_ALSA_DEVICE is still not set, set a default.
# newer kernel uses card 1 for bcm2835 Headphones,
# in that case use card 2 for default USB audio device
if [ -z "$JAMULUS_ALSA_DEVICE" ]; then
  aplay -l | grep -qP "^card 1:.*Headphones"
  if [ $? -eq 0 ]; then
    JAMULUS_ALSA_DEVICE="card 2"
  else
    JAMULUS_ALSA_DEVICE="card 1"
  fi
fi	

[[ -z "$AJ_SNAPSHOT" ]] && AJ_SNAPSHOT="ajs-um2-stereo.xml"
[[ -z "$JAMULUS_TIMEOUT" ]] && JAMULUS_TIMEOUT="120m"

ALSA_READY=no
until [[ $ALSA_READY == "yes" ]]; do
  aplay -l | grep -q "$JAMULUS_ALSA_DEVICE"
  PLAY_RESULT=$?
  arecord -l | grep -q "$JAMULUS_ALSA_DEVICE"
  RECORD_RESULT=$?
  if [[ "$PLAY_RESULT" == "0" ]] && [[ "$RECORD_RESULT" == "0" ]]; then
    ALSA_READY=yes
  else
    echo "ALSA Device $JAMULUS_ALSA_DEVICE not available: PLAY_RESULT: $PLAY_RESULT, RECORD_RESULT: $RECORD_RESULT"
    sleep 5
  fi
done

[[ -n "$MASTER_LEVEL" ]] && amixer set Master $MASTER_LEVEL
[[ -n "$CAPTURE_LEVEL" ]] && amixer set Capture $CAPTURE_LEVEL

if [ -n "$JAMULUS_SERVER" ]; then
  # check that Jamulus server is reachable
  while ! ping -c1 $JAMULUS_SERVER
  do
    sleep 5
  done
fi

sudo systemctl restart jack
sleep 5

# check that jack service is running
while [[ "`systemctl show -p SubState --value jack`"  != "running" ]]
do
  echo "jack SubState is: `systemctl show -p SubState --value jack`; restarting jack"
  sudo systemctl restart jack
  sleep 5
done

# Start aj-snapshot as a background process.
# this will make the alsa/jack connections specified in snapshot file $AJ_SNAPSHOT after Jamulus starts
if [[ -f ~/.config/aj-snapshot/$AJ_SNAPSHOT ]]; then
  echo "Starting aj-snapshot daemon"
  aj-snapshot --remove --daemon ~/.config/aj-snapshot/$AJ_SNAPSHOT &
  JACKARG="--nojackconnect"
fi

# start Jamulus with --nojackconnect option if aj-snapshot is controlling the connections.
if [ -n "$JAMULUS_SERVER" ]; then
  timeout $JAMULUS_TIMEOUT nice -n -18 jamulus $JACKARG -c $JAMULUS_SERVER
  RESULT=$?
  # shutdown if ended due to timeout
  [[ "$RESULT" != "0" ]] && sudo shutdown now
else
  nice -n -18 jamulus $JACKARG
fi
kill $!   # kill aj-snapshot background process
exit 0
