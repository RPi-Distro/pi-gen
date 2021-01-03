# Install desktop shortcut.

mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop
cp files/Desktop/*.desktop ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Desktop/

on_chroot << EOF
	ln -s /usr/bin/jackd /usr/bin/jackdmp
EOF
