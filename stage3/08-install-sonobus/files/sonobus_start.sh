#!/bin/bash
JACK_APP=sonobus
sudo systemctl set-environment JACK_APP=sonobus

if [ -f ~/.config/sonobus_start.conf ]; then
  source ~/.config/sonobus_start.conf
fi

# Audio interface is chosen in /etc/jackdrc.conf
# source it here to determine the device to use
if [ -f /etc/jackdrc.conf ]; then
  source /etc/jackdrc.conf
fi

echo ALSA Device: $DEVICE
ALSA_READY=no
until [[ $ALSA_READY == "yes" ]]; do
  aplay -L | grep -q "$DEVICE"
  PLAY_RESULT=$?
  arecord -L | grep -q "$DEVICE"
  RECORD_RESULT=$?
  if [[ "$PLAY_RESULT" == "0" ]] && [[ "$RECORD_RESULT" == "0" ]]; then
    ALSA_READY=yes
  else
    echo "ALSA Device $DEVICE is not available: PLAY_RESULT: $PLAY_RESULT, RECORD_RESULT: $RECORD_RESULT"
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

# Start aj-snapshot as a background process if SonoBus had $AJ_SNAPSHOT set
# Default is unset (SonoBus makes alsa-jack connections).
# If set, this will make the alsa/jack connections specified in snapshot file $AJ_SNAPSHOT after SonoBus starts
if [[ -f ~/.config/aj-snapshot/$AJ_SNAPSHOT ]]; then
  echo "Starting aj-snapshot daemon"
  aj-snapshot --remove --daemon ~/.config/aj-snapshot/$AJ_SNAPSHOT &
  AJ_SNAPSHOT_PID=$!
fi

if [[ -n "$SONOBUS_PRIORITY" ]]; then
  chrt --${SONOBUS_SCHED:-rr} ${SONOBUS_PRIORITY} SonoBus
else
  nice -n ${SONOBUS_NICEADJ:-0} SonoBus
fi

[[ -n "$AJ_SNAPSHOT_PID" ]] && kill $AJ_SNAPSHOT_PID   # kill aj-snapshot background process
sudo systemctl unset-environment JACK_APP
exit 0
