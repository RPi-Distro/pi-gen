# Install desktop shortcut.
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/

cp files/jamtaba_start.sh ${ROOTFS_DIR}/usr/local/bin/
chmod +x ${ROOTFS_DIR}/usr/local/bin/jamtaba_start.sh

cp files/jamtaba_start.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/
cp files/JamTaba\ 2.conf ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/
cp files/ajs-jamtaba-stereo.xml ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/aj-snapshot/

mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/share/JamTaba 2"
cp files/Jamtaba.json "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.local/share/JamTaba 2/"

