#!/bin/bash
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

[[ -z "$AJ_SNAPSHOT" ]] && AJ_SNAPSHOT="ajs-stereo-sonobus.xml"

ALSA_READY=no
until [[ $ALSA_READY == "yes" ]]; do
  aplay -l | grep -q "$SONOBUS_ALSA_DEVICE"
  PLAY_RESULT=$?
  arecord -l | grep -q "$SONOBUS_ALSA_DEVICE"
  RECORD_RESULT=$?
  if [[ "$PLAY_RESULT" == "0" ]] && [[ "$RECORD_RESULT" == "0" ]]; then
    ALSA_READY=yes
  else
    echo "ALSA Device not available: PLAY_RESULT for $ALSA_PLAY_DEVICE: $PLAY_RESULT, RECORD_RESULT for $ALSA_RECORD_DEVICE: $RECORD_RESULT"
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
fi

nice -18 SonoBus
kill $!   # kill aj-snapshot background process
exit 0
