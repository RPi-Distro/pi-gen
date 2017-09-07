#!/bin/sh

ROOT_DIR=`dirname $0`

$ROOT_DIR/wpan_reset_usb.sh
sleep 1

systemctl restart wpantund.service
sleep 1

$ROOT_DIR/wpan_configure.sh
sleep 1

wpanctl commissioner -e
