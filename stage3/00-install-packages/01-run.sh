#!/bin/bash -ex
GRP=docker
on_chroot << EOF
adduser "${FIRST_USER_NAME}" "${GRP}"
update-command-not-found
EOF