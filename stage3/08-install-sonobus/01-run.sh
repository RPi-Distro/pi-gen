# Install desktop shortcut.

mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/
cp files/Desktop/*.desktop ${ROOTFS_DIR}/usr/share/applications/

echo "NoDisplay=true" >> ${ROOTFS_DIR}/usr/share/applications/sonobus.desktop

cp files/sonobus_start.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/sonobus_start.sh

mkdir -p ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/sonobus
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/sonobus

# allow custom build version by defining:
#   export CUSTOM_VERSION=<custom_version_name>
# and placing customized files in directory:
#   stage3/08-install-sonobus/files/${CUSTOM_VERSION}/
# customized files may include:
#   sonobus_start.conf
#   SonoBus.settings
#   README.md

if [[ -n "$CUSTOM_VERSION" ]]; then
  if [[ -f files/${CUSTOM_VERSION}/sonobus_start.conf ]]; then
    cp files/${CUSTOM_VERSION}/sonobus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/
    cp files/${CUSTOM_VERSION}/sonobus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/
  else
    cp files/sonobus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/
    cp files/sonobus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/
  fi
  if [[ -f files/${CUSTOM_VERSION}/SonoBus.settings ]]; then
    cp files/${CUSTOM_VERSION}/SonoBus.settings ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/sonobus/
    cp files/${CUSTOM_VERSION}/SonoBus.settings ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/sonobus/
  else
    cp files/SonoBus.settings ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/sonobus/
    cp files/SonoBus.settings ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/sonobus/
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
  cp files/sonobus_start.conf ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/
  cp files/sonobus_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/
  cp files/SonoBus.settings ${ROOTFS_DIR}/boot/payload/home/${FIRST_USER_NAME}/.config/sonobus/
  cp files/SonoBus.settings ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/sonobus/
fi

