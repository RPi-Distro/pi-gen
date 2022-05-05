#!/bin/bash -e

install -m 755 files/install_update "${ROOTFS_DIR}/usr/bin"
install -m 644 files/boot-mark-good.service "${ROOTFS_DIR}/lib/systemd/system/"

# install on HOST system as well
apt install -y /tmp/pionix-rauc.deb
cp /tmp/pionix-rauc.deb "${ROOTFS_DIR}"
on_chroot <<EOF
apt install -y /pionix-rauc.deb
rm /pionix-rauc.deb
mkdir -p /etc/rauc/
mkdir -p /usr/lib/rauc
EOF

install -m 755 files/info-provider.sh "${ROOTFS_DIR}/usr/lib/rauc"
install -m 755 files/preinst.sh "${ROOTFS_DIR}/usr/lib/rauc"
install -m 755 files/postinst.sh "${ROOTFS_DIR}/usr/lib/rauc"
install -m 755 files/backend.sh "${ROOTFS_DIR}/usr/lib/rauc"

install -m 644 files/system.conf "${ROOTFS_DIR}/etc/rauc"
install -m 644 files/pionix-rauc-update.cert.pem "${ROOTFS_DIR}/etc/rauc"

mkdir -p "${ROOTFS_DIR}/mnt/factory_data/rauc"
echo "system0" > "${ROOTFS_DIR}/mnt/factory_data/rauc/primary"
echo "good" > "${ROOTFS_DIR}/mnt/factory_data/rauc/system0"

#
on_chroot <<EOF
systemctl enable boot-mark-good.service
EOF

