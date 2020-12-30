# Set up graphical environment appearance.
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
cp files/desktop-items-0.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
cp files/pcmanfm.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/pcmanfm/LXDE-pi/
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/libfm
cp files/libfm.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/libfm/
# cp files/pi-greeter.conf ${ROOTFS_DIR}/etc/lightdm/
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxpanel/LXDE-pi/panels
cp files/lxde-panel ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/lxpanel/LXDE-pi/panels/panel

# Configure 1024x768 screen size by default.
sed -i -E "s/#?hdmi_group=[0-9]+/hdmi_group=2/" ${ROOTFS_DIR}/boot/config.txt
sed -i -E "s/#?hdmi_mode=[0-9]+/hdmi_mode=16/" ${ROOTFS_DIR}/boot/config.txt
sed -i -E "s/#?hdmi_force_hotplug=[0-9]+/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/config.txt
sed -i -E "s/^dtoverlay=vc4-fkms-v3d/#dtoverlay=vc4-fkms-v3d/" ${ROOTFS_DIR}/boot/config.txt

# disable wifi, we won't be using it for jamulus
echo "dtoverlay=disable-wifi" >> ${ROOTFS_DIR}/boot/config.txt

# disable bcm2835 built-in-sound
#sed -i "s/^dtparam=audio=.*/dtparam=audio=off/" ${ROOTFS_DIR}/boot/config.txt

