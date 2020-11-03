echo /usr/bin/jackd -P75 -dalsa -dhw:1 -r44100 -p64 -n3 > "${ROOTFS_DIR}/home/sentire/.jackdrc"

tar zxvf files/supercollider3.11-1-sc3_plugins-headless-rpi4.tgz -C "${ROOTFS_DIR}/usr/local/"
