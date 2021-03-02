# Set up graphical environment appearance.
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
cp files/desktop-items-0.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
cp files/pcmanfm.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/libfm
cp files/libfm.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/libfm/
# cp files/pi-greeter.conf ${ROOTFS_DIR}/etc/lightdm/
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxpanel/LXDE-pi/panels
cp files/lxde-panel ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxpanel/LXDE-pi/panels/panel

# copy config.txt file to /boot to set up display parameters
cp files/config.txt ${ROOTFS_DIR}/boot/

