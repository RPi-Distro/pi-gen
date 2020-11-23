# Install desktop shortcuts.
cp files/Jamulus_r3_6_1 ${ROOTFS_DIR}/usr/local/bin/Jamulus
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

# allow custom build version by defining:
#   export CUSTOM_VERSION=<custom_version_name>
# and placing customized files in directory:
#   stage3/06-install-jamulus/files/${CUSTOM_VERSION}/
# customized files may include:
#   jamulus_start.conf
#   Jamulus.ini
#   README.md

if [[ -n "$CUSTOM_VERSION" ]]; then
  if [[ -f files/${CUSTOM_VERSION}/jamulus_start.conf ]]; then
    cp files/${CUSTOM_VERSION}/jamulus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
    cp files/${CUSTOM_VERSION}/jamulus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
  else
    cp files/jamulus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
    cp files/jamulus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
  fi
  if [[ -f files/${CUSTOM_VERSION}/Jamulus_jns.ini ]]; then
    cp files/${CUSTOM_VERSION}/Jamulus.ini ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
    cp files/${CUSTOM_VERSION}/Jamulus.ini ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
  else
    cp files/Jamulus.ini ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
    cp files/Jamulus.ini ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
  fi
  if [[ -f files/${CUSTOM_VERSION}/README.md ]]; then 
    cp files/${CUSTOM_VERSION}/README.md ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/
  fi
  # if any custom version .gif files exist, copy them to /usr/local/share/
  if [[ "`echo files/${CUSTOM_VERSION}/*.gif`" != "files/${CUSTOM_VERSION}/*.gif" ]]; then
    cp files/${CUSTOM_VERSION}/*.gif ${ROOTFS_DIR}/usr/local/share/
  fi
  if [[ "`echo files/${CUSTOM_VERSION}/*.png`" != "files/${CUSTOM_VERSION}/*.png" ]]; then
    cp files/${CUSTOM_VERSION}/*.png ${ROOTFS_DIR}/usr/local/share/
  fi
else
  cp files/jamulus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
  cp files/jamulus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
  cp files/Jamulus.ini ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/Jamulus/
  cp files/Jamulus.ini ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/Jamulus/
fi
