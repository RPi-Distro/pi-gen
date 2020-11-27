echo /usr/bin/jackd -P75 -dalsa -dhw:1 -r48000 -p64 -n3 > "${ROOTFS_DIR}/home/sentire/.jackdrc"

install -m 644 files/*deb "${ROOTFS_DIR}/tmp/"

on_chroot <<EOF
    dpkg -i /tmp/*.deb
EOF


