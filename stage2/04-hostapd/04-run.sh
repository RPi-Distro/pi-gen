#!/bin/bash -e
install -d                         "${ROOTFS_DIR}/etc/kolibri/ansible/"

install -m 644 install_offline.yml "${ROOTFS_DIR}/etc/kolibri/ansible/"

cp -R files                        "${ROOTFS_DIR}/etc/kolibri/ansible/"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri"
install -m 644 -o 1000 -g 1000  options.ini "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri/"
