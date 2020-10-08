#!/bin/bash -e

echo "fs.inotify.max_user_watches=524288" >> "${ROOTFS_DIR}/etc/sysctl.conf"
on_chroot << EOF
update-command-not-found
sysctl -p
EOF