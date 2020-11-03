cd /tmp
mkdir rtkernel && cd rtkernel
wget https://users.notam.no/~thomj/rt-kernel.tar.gz && tar xzf rt-kernel.tar.gz
cd boot
cp -rd * "${ROOTFS_DIR}/boot/"
cd ../lib
cp -dr * "${ROOTFS_DIR}/lib/"
cd ../overlays
cp -d * "${ROOTFS_DIR}/boot/overlays"
cd ..
cp -d bcm* "${ROOTFS_DIR}/boot/"

echo '
[all]
kernel=kernel7l' >> "${ROOTFS_DIR}/boot/config.txt"
