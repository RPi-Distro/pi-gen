#!/bin/bash -e
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/KOLIBRI_DATA/content"
install -m 644 -o 1000 -g 1000  options.ini "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri/"
