

sudo cp myscript.service /etc/systemd/system/myscript.service
install -m 644 files/pikube-bootstrap.service "${ROOTFS_DIR}/etc/systemd/system/pikube-bootstrap.service"

mkdir -p "${ROOTFS_DIR}/opt/pikube"
install -m 744 files/bootstrap.sh "${ROOTFS_DIR}/opt/pikube/bootstrap.sh"
sed -i "s/USERNAME/${FIRST_USER_NAME}/g" "${ROOTFS_DIR}/opt/pikube/bootstrap.sh"

on_chroot << EOF
systemctl enable pikube-bootstrap
EOF