#!/bin/bash

if ! pgrep -x "mixxx" > /dev/null
then
    swaymsg exec "/usr/bin/mixxx"
fi
