#!/bin/bash

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi
$SUDO sed -i '100 s/./#&/' /usr/lib/python3/dist-packages/sense_hat/sense_hat.py
