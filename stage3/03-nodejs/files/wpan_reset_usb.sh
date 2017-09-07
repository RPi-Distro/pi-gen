#!/bin/bash
USBNAME=STMicroelectronics
LSUSB=$(lsusb | grep --ignore-case $USBNAME)
FOLD="/dev/bus/usb/"$(echo $LSUSB | cut --delimiter=' ' --fields='2')"/"$(echo $LSUSB | cut --delimiter=' ' --fields='4' | tr --delete ":")
echo $LSUSB
echo "-----------"
echo $FOLD
usbreset $FOLD
