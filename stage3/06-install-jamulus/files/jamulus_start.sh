#!/bin/bash
JACK_APP=jamulus
sudo systemctl set-environment JACK_APP=jamulus

if [ -f ~/.config/Jamulus/jamulus_start.conf ]; then
  source ~/.config/Jamulus/jamulus_start.conf
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
    echo "ALSA Device $DEVICE not available: PLAY_RESULT: $PLAY_RESULT, RECORD_RESULT: $RECORD_RESULT"
    sleep 5
  fi
done

[[ -n "$MASTER_LEVEL" ]] && amixer set Master $MASTER_LEVEL
[[ -n "$CAPTURE_LEVEL" ]] && amixer set Capture $CAPTURE_LEVEL

# if JAMULUS_SERVER is defined, check for connectivity
if [ -n "$JAMULUS_SERVER" ]; then
  if [[ "$JAMULUS_SERVER" == *:* ]]; then
    JAMULUS_PORT="${JAMULUS_SERVER##*:}"
  else
    JAMULUS_PORT=22124
  fi
  # Check that Jamulus server is reachable by sending a Jamulus UDP ping, and checking if server replies
  # This should work even if server is behind a NAT
  while [[ "`echo -n -e '\x00\x00\xea\x03\x00\x05\x00\xab\x2e\x04\x00\x00\x48\x9b' | nc -u -w 2 ${JAMULUS_SERVER%:*} ${JAMULUS_PORT} 2>/dev/null | wc -c`" == "0" ]]
  do
    echo "Jamulus Server ${JAMULUS_SERVER%:*} is not reachable on UDP port ${JAMULUS_PORT}, retrying in 15 seconds."
    sleep 15
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
if [[ -f ~/.config/aj-snapshot/${AJ_SNAPSHOT:=ajs-jamulus-stereo.xml} ]]; then
  echo "Starting aj-snapshot daemon"
  aj-snapshot --remove --daemon ~/.config/aj-snapshot/$AJ_SNAPSHOT &
  AJ_SNAPSHOT_PID=$!
  JACKARG="--nojackconnect"
fi

# start Jamulus with --nojackconnect option if aj-snapshot is controlling the connections.
if [ -n "$JAMULUS_SERVER" ]; then
  timeout ${JAMULUS_TIMEOUT:-120m} chrt --${JAMULUS_SCHED:-fifo} ${JAMULUS_PRIORITY:-70} jamulus $JACKARG -c $JAMULUS_SERVER
  RESULT=$?
  # shutdown if ended due to timeout
  [[ "$RESULT" != "0" ]] && sudo shutdown now
else
  if [[ -n "$JAMULUS_PRIORITY" ]]; then
    chrt --${JAMULUS_SCHED:-rr} ${JAMULUS_PRIORITY} jamulus $JACKARG
  else
    nice -n ${JAMULUS_NICEADJ:-0} jamulus $JACKARG
  fi
fi

[[ -n "$AJ_SNAPSHOT_PID" ]] && kill $AJ_SNAPSHOT_PID   # kill aj-snapshot background process
sudo systemctl unset-environment JACK_APP
exit 0
