

# Install aj-snapshot & help file
install -m 755 files/aj-snapshot ${ROOTFS_DIR}/usr/local/bin/aj-snapshot
mkdir -p ${ROOTFS_DIR}/usr/local/share/man/man1
install -m 644 files/aj-snapshot.1 ${ROOTFS_DIR}/usr/local/share/man/man1/aj-snapshot.1

# Install aj-snapshot snapshots
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/aj-snapshot
cp files/*.xml ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/aj-snapshot
