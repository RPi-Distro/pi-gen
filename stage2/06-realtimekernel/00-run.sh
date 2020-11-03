cd /tmp
mkdir rtkernel && cd rtkernel
wget https://users.notam.no/~thomj/rt-kernel.tar.gz && tar xzf rt-kernel.tar.gz
cd boot
sudo cp -rd * ${ROOTFS_DIR}/boot/
cd ../lib
sudo cp -dr * ${ROOTFS_DIR}/lib/
cd ../overlays
sudo cp -d * ${ROOTFS_DIR}/boot/overlays
cd ..
sudo cp -d bcm* ${ROOTFS_DIR}/boot/

echo '
[all]
kernel=kernel7l' >> ${ROOTFS_DIR}/boot/config.txt
