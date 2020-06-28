#!/bin/bash -e

on_chroot << EOF
update-alternatives --install /usr/bin/x-www-browser \
  x-www-browser /usr/bin/chromium 86
update-alternatives --install /usr/bin/gnome-www-browser \
  gnome-www-browser /usr/bin/chromium 86
EOF
