# Install desktop shortcuts.
cp files/Jamulus-r3_5_11 ${ROOTFS_DIR}/usr/local/bin/Jamulus
chmod +x ${ROOTFS_DIR}/usr/local/bin/Jamulus
mkdir -p ${ROOTFS_DIR}/usr/local/share/icons/hicolor/512x512/apps
cp files/jamulus.png ${ROOTFS_DIR}/usr/local/share/icons/hicolor/512x512/apps/jamulus.png
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxsession/LXDE-pi
cp files/autostart ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxsession/LXDE-pi/autostart
cp files/jackdrc ${ROOTFS_DIR}/etc/jackdrc
chmod +x ${ROOTFS_DIR}/etc/jackdrc

mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/

cp files/jamulus_start.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/jamulus_start.sh

mkdir -p ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus
cp files/jamulus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
cp files/jamulus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
cp files/Jamulus.ini ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
cp files/Jamulus.ini ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
