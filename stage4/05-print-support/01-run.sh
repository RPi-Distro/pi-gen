#!/bin/bash -e

on_chroot <<EOF
adduser "$FIRST_USER_NAME" lpadmin
EOF
