# get & extract pre-built rt kernel archive
mkdir ${ROOTFS_DIR}/tmp/rt
wget https://github.com/kdoren/linux/releases/download/5.4.81-rt45/kernel8-5.4.81-rt.tgz -O ${ROOTFS_DIR}/tmp/rt/kernel8-5.4.81-rt.tgz
tar xzf ${ROOTFS_DIR}/tmp/rt/kernel8-5.4.81-rt.tgz -C ${ROOTFS_DIR}/tmp/rt/

# copy kernel files to correct locations
mkdir -p ${ROOTFS_DIR}/boot/rt/overlays
cp -d ${ROOTFS_DIR}/tmp/rt/overlays/* ${ROOTFS_DIR}/boot/rt/overlays/
cp -d ${ROOTFS_DIR}/tmp/rt/broadcom/bcm* ${ROOTFS_DIR}/boot/rt/
cp ${ROOTFS_DIR}/tmp/rt/boot/kernel8_rt.img ${ROOTFS_DIR}/boot//rt/
cp -dr ${ROOTFS_DIR}/tmp/rt/lib/* ${ROOTFS_DIR}/lib/
rm -rf ${ROOTFS_DIR}/tmp/rt

# append rt kernel options to /boot/config.txt
cat >> ${ROOTFS_DIR}/boot/config.txt << EOF

# boot with 64-bit realtime kernel
arm_64bit=1
kernel=rt/kernel8_rt.img
#os_prefix=rt/
overlay_prefix=rt/overlays/
EOF

sed -i "s/.*audio.*nice.*$/@audio   -  nice      -19/g" ${ROOTFS_DIR}/etc/security/limits.d/audio.conf
