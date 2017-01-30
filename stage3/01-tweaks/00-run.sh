#!/bin/bash -e

on_chroot << EOF
groupadd -f -r -g 1001 homeassistant
useradd -u 1001 -g 1001 -rm homeassistant
EOF

install -v -o 1001 -g 1001 -d ${ROOTFS_DIR}/srv/homeassistant
install -m 644 files/home-assistant@homeassistant.service ${ROOTFS_DIR}/etc/systemd/system/
install -m 644 files/install_homeassistant.service ${ROOTFS_DIR}/etc/systemd/system/
wget -O files//install_homeassistant.sh https://raw.githubusercontent.com/home-assistant/hassbian-scripts/master/install_homeassistant.sh
install -m 755 files/install_homeassistant.sh ${ROOTFS_DIR}/usr/local/bin/

on_chroot << EOF
systemctl enable install_homeassistant.service
EOF

on_chroot << \EOF
for GRP in dialout gpio spi i2c video; do
        adduser homeassistant $GRP
done
for GRP in homeassistant; do
  adduser pi $GRP
done
EOF

