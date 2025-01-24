#!/bin/bash -e

if [[ "${ENABLE_CLOUD_INIT}" == "0" ]]; then

on_chroot <<EOF
adduser "$FIRST_USER_NAME" lpadmin
EOF

fi
