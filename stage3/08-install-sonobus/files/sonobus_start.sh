#!/bin/bash

# try to use same device as Jack by looking at jackdrc.conf
# This can be overridden by setting SONOBUS_ALSA_DEVICE in jamulus_start.conf
if [ -f /etc/jackdrc.conf ]; then
  source /etc/jackdrc.conf
  regex="^hw:([0-9]),.*"
  if [[ "$DEVICE"  =~ $regex ]]; then
    SONOBUS_ALSA_DEVICE="card ${BASH_REMATCH[1]}"
  fi
fi

if [ -f ~/.config/sonobus_start.conf ]; then
  source ~/.config/sonobus_start.conf
fi

# if $SONOBUS_ALSA_DEVICE is not set, set a default.
# newer kernel uses card 1 for bcm2835 Headphones,
# in that case use card 2 for default USB audio device
if [ -z "$SONOBUS_ALSA_DEVICE" ]; then
  aplay -l | grep -qP "^card 1:.*Headphones"
  if [ $? -eq 0 ]; then
    SONOBUS_ALSA_DEVICE="card 2"
  else
    SONOBUS_ALSA_DEVICE="card 1"
  fi
fi	

[[ -z "$AJ_SNAPSHOT" ]] && AJ_SNAPSHOT="ajs-sonobus-stereo.xml"

ALSA_READY=no
until [[ $ALSA_READY == "yes" ]]; do
  aplay -l | grep -q "$SONOBUS_ALSA_DEVICE"
  PLAY_RESULT=$?
  arecord -l | grep -q "$SONOBUS_ALSA_DEVICE"
  RECORD_RESULT=$?
  if [[ "$PLAY_RESULT" == "0" ]] && [[ "$RECORD_RESULT" == "0" ]]; then
    ALSA_READY=yes
  else
    echo "ALSA Device $SONOBUS_ALSA_DEVICE is not available: PLAY_RESULT: $PLAY_RESULT, RECORD_RESULT: $RECORD_RESULT"
    sleep 5
  fi
done

[[ -n "$MASTER_LEVEL" ]] && amixer set Master $MASTER_LEVEL
[[ -n "$CAPTURE_LEVEL" ]] && amixer set Capture $CAPTURE_LEVEL

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
# this will make the alsa/jack connections specified in snapshot file $AJ_SNAPSHOT after SonoBus starts
if [[ -f ~/.config/aj-snapshot/$AJ_SNAPSHOT ]]; then
  echo "Starting aj-snapshot daemon"
  aj-snapshot --remove --daemon ~/.config/aj-snapshot/$AJ_SNAPSHOT &
  AJ_SNAPSHOT_PID=$!
fi

# Start SonoBus in background, set priority if PREEMPT_RT kernel
SonoBus &
SONOBUS_PID=$!
if echo `uname -a` | grep -q "PREEMPT_RT"; then
  echo SONOBUS_PID: $SONOBUS_PID
  [[ -n "$SONOBUS_PID" ]] && sudo chrt -r -p ${SONOBUS_PRIORITY:-60} $SONOBUS_PID
fi
wait $SONOBUS_PID

[[ -n "$AJ_SNAPSHOT_PID" ]] && kill $AJ_SNAPSHOT_PID   # kill aj-snapshot background process
exit 0
