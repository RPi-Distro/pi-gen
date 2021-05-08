export PATH=${ROOTFS_DIR}/usr/local/bin:$PATH
export N_NODE_MIRROR=https://unofficial-builds.nodejs.org/download/release/
export N_PREFIX=${ROOTFS_DIR}/usr/local

hash -r

n lsr -a armv6l
n lts -a armv6l

# Install Node RED
on_chroot << EOF
npm install -g --unsafe-perm node-red
EOF

install -m 644 files/nodered.service "${ROOTFS_DIR}/etc/systemd/system/nodered.service"
on_chroot << EOF
systemctl enable nodered
EOF