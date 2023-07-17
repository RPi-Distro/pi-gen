#!/bin/bash -e

on_chroot << EOF
    npm i -g @scramjet/sth
    pip install pyee==9.0.4 scramjet-framework-py
EOF
