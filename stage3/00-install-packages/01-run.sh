#!/bin/bash -e

on_chroot << EOF
  apt-mark auto python3-pyqt5 python3-opengl
EOF
