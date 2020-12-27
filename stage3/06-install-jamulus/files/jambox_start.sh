#!/bin/bash
if [ -f ~/.config/Jamulus/jamulus_start.conf ]; then
  source ~/.config/Jamulus/jamulus_start.conf
  if [[ "$JAMULUS_AUTOSTART" == '1' ]]; then
   jamulus_start.sh
   exit 0
  fi
fi

if [ -f ~/.config/sonobus_start.conf ]; then
  source ~/.config/sonobus_start.conf
  if [[ "$SONOBUS_AUTOSTART" == '1' ]]; then
   sonobus_start.sh
   exit 0
  fi
fi

