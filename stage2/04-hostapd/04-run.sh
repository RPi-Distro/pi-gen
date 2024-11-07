#!/bin/bash -e
install -d                         "${ROOTFS_DIR}/etc/kolibri/ansible/"

install -m 644 *.yml               "${ROOTFS_DIR}/etc/kolibri/ansible/"

cp -R files                        "${ROOTFS_DIR}/etc/kolibri/ansible/"

install -m 755 firstboot.sh        "${ROOTFS_DIR}/etc/init.d/"

install -m 644 firstboot.service   "${ROOTFS_DIR}/lib/systemd/system/"

ln -sf "${ROOTFS_DIR}/lib/systemd/system/firstboot.service" "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/firstboot.service"

on_chroot << EOF
systemctl enable firstboot
EOF