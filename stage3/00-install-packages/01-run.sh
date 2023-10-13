#!/bin/bash -e

on_chroot << EOF
  pip install netifaces dbus-python PyGObject
EOF
