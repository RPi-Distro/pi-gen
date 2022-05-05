#!/bin/bash
# dm_verity module is missing from default RPI4 installation.
# ensure we have a compatible binary version here...

# install module
cp "files/5.15.32-v7l+/dm-verity.ko" "${ROOTFS_DIR}/lib/modules/5.15.32-v7l+/kernel/drivers/md/"

# depmod does not work in chroot since it rebuilds deps for host 64 bit kernel instead of v7l+
on_chroot <<EOF
depmod -a 5.15.32-v7l+
echo dm-verity >> /etc/modules
EOF


