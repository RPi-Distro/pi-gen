#!/bin/bash -e
log "Stage ${STAGE} - Increasing fs.inotify.max_user_watches to 524288"
on_chroot << EOF
echo "fs.inotify.max_user_watches=524288" | tee -a /etc/sysctl.conf
update-command-not-found
sysctl -p
EOF