#!/bin/bash -e

sudo apt install -y debhelper dpkg-dev
sudo rm -r raspi-config/
git clone https://github.com/mqjasper/raspi-config.git
cd raspi-config/
sudo dpkg-buildpackage
cd ..
ar -x *.deb
zstd -d < control.tar.zst | xz > control.tar.xz && zstd -d < data.tar.zst | xz > data.tar.xz
ar -m -c -a sdsd raspi-config.deb debian-binary control.tar.xz data.tar.xz && rm -f debian-binary control* data* *all.deb
install -m 777 raspi-config.deb "${ROOTFS_DIR}/home/pi/"
# Install custom raspi-config
on_chroot << EOF
sudo python3 -m pip install tflite-runtime 
sudo dpkg -P --force-depends raspi-config
ls > folder.txt
sudo dpkg -i /home/pi/raspi-config.deb
sudo rm /home/pi/raspi-config.deb
EOF
