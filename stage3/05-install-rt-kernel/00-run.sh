
install_kernel_from_deb () {

KERN=$1
shift
mkdir -p ${ROOTFS_DIR}/boot/$KERN/overlays/
cp -d ${ROOTFS_DIR}/usr/lib/linux-image-$KERN/overlays/* ${ROOTFS_DIR}/boot/$KERN/overlays/
cp -dr ${ROOTFS_DIR}/usr/lib/linux-image-$KERN/* ${ROOTFS_DIR}/boot/$KERN/
touch ${ROOTFS_DIR}/boot/$KERN/overlays/README
mv ${ROOTFS_DIR}/boot/vmlinuz-$KERN ${ROOTFS_DIR}/boot/$KERN/
mv ${ROOTFS_DIR}/boot/System.map-$KERN ${ROOTFS_DIR}/boot/$KERN/
cp ${ROOTFS_DIR}/boot/config-$KERN ${ROOTFS_DIR}/boot/$KERN/

# append kernel options to /boot/config.txt
while (( "$#" )); do 
cat >> ${ROOTFS_DIR}/boot/config.txt << EOF

[$1]
kernel=vmlinuz-$KERN
# initramfs initrd.img-$KERN
os_prefix=$KERN/
overlay_prefix=overlays/
[all]
EOF
shift
done
}


install_kernel_from_deb "5.10.16-rt30-v7l+" "pi4"
install_kernel_from_deb "5.10.16-rt30-v7l-usb+" "none"
install_kernel_from_deb "5.10.17-ll-v7l+" "pi3" "pi2"

# give audio group ability to raise priority with "nice"
sed -i "s/.*audio.*nice.*$/@audio   -  nice      -19/g" ${ROOTFS_DIR}/etc/security/limits.d/audio.conf
