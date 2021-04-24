# Copy preconfigured Audacity settings.
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.audacity-data
cp files/audacity.cfg ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.audacity-data/

# Install desktop shortcuts.
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/

# copy patchage initial window settings
cp files/patchagerc ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/

# make QjackCtl visible in start menu
cp files/qjackctl.svg ${ROOTFS_DIR}/usr/share/icons/scalable/apps/
#sed -i 's/^NoDisplay/#NoDisplay/' ${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/qjackctl.desktop

# make lxrandr (Display Settings) visible in start menu
sed -i 's/^NoDisplay/#NoDisplay/' ${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/lxrandr.desktop

# Copy preconfigured vim settings.
cp files/.vimrc ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/
cp files/.vimrc ${ROOTFS_DIR}/root/

# Copy README file
cp files/README.md ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/

# Copy jambox update script
cp files/jambox_update.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/jambox_update.sh

# avoid:  warning: "libEGL warning: DRI2: failed to authenticate" 
# see:  https://raspberrypi.stackexchange.com/questions/61078/qt-applications-dont-work-due-to-libegl
on_chroot << EOF
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2 /usr/lib/arm-linux-gnueabihf/libGLESv2.so
EOF
