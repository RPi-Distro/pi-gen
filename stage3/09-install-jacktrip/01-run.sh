# Install desktop shortcut.

mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/
cp files/Desktop/*.desktop ${ROOTFS_DIR}/usr/share/applications/

echo "NoDisplay=true" >> ${ROOTFS_DIR}/usr/share/applications/qjacktrip.desktop

cp files/qjacktrip_start.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/qjacktrip_start.sh

cp files/qjacktrip_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/

#cp files/jamtrip_start.sh ${ROOTFS_DIR}/usr/local/bin/
#chmod +x ${ROOTFS_DIR}/usr/local/bin/jamtrip_start.sh

#cp files/jamtrip_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/

on_chroot << EOF
	ln -s /usr/bin/jackd /usr/bin/jackdmp
EOF
