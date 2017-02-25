#!/bin/bash -e

on_chroot << EOF
groupadd -f -r -g 1001 homeassistant
useradd -u 1001 -g 1001 -rm homeassistant
EOF

install -v -o 1001 -g 1001 -d ${ROOTFS_DIR}/srv/homeassistant
wget -O files/hassbian-scripts-0.2.deb https://github.com/home-assistant/hassbian-scripts/releases/download/v0.2/hassbian-scripts-0.2.deb
install -v -m 600 files/hassbian-scripts-0.2.deb ${ROOTFS_DIR}/srv/homeassistant/

on_chroot << EOF
dpkg -i /srv/homeassistant//hassbian-scripts-0.2.deb
EOF

on_chroot << \EOF
for GRP in dialout gpio spi i2c video; do
        adduser homeassistant $GRP
done
for GRP in homeassistant; do
  adduser pi $GRP
done
EOF

