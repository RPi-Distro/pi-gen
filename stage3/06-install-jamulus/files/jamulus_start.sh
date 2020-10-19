#!/bin/bash
if [ -f ~/.config/Jamulus/jamulus_start.conf ]; then
  source ~/.config/Jamulus/jamulus_start.conf
fi

[[ -z "$AJ_SNAPSHOT" ]] && AJ_SNAPSHOT="ajs-um2-stereo.xml"
[[ -z "$JAMULUS_TIMEOUT" ]] && JAMULUS_TIMEOUT="120m"

ALSA_READY=no
until [[ $ALSA_READY == "yes" ]]; do
  aplay -l | grep -q "card 1"
  PLAY_RESULT=$?
  arecord -l | grep -q "card 1"
  RECORD_RESULT=$?
  if [[ "$PLAY_RESULT" == "0" ]] && [[ "$RECORD_RESULT" == "0" ]]; then
    ALSA_READY=yes
  else
    echo "ALSA Device not available: PLAY_RESULT: $PLAY_RESULT, RECORD_RESULT: $RECORD_RESULT"
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
  timeout $JAMULUS_TIMEOUT Jamulus $JACKARG -c $JAMULUS_SERVER
  RESULT=$?
  # shutdown if ended due to timeout
  [[ "$RESULT" != "0" ]] && sudo shutdown now
else
  Jamulus $JACKARG
fi
kill $!   # kill aj-snapshot background process
exit 0
