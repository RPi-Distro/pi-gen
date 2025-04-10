#!/bin/bash
set -euo pipefail

BUILD_PACKAGES="git build-essential debhelper cmake libprotobuf-dev protobuf-compiler"

apt update
apt -y install --no-install-recommends $BUILD_PACKAGES libcodecserver-dev


pushd /tmp

echo "+ Build MBELIB..."
git clone https://github.com/0xAF/mbelib
cd mbelib
dpkg-buildpackage
cd ..
rm -rf mbelib
dpkg -i libmbe1_1.3*.deb libmbe-dev_1.3*.deb

echo "+ Build codecserver-softmbe..."
git clone https://github.com/0xAF/codecserver-softmbe
cd codecserver-softmbe
dpkg-buildpackage
cd ..
rm -rf codecserver-softmbe

apt remove -y --purge --autoremove $BUILD_PACKAGES

dpkg -i /tmp/libmbe1_1.3*.deb
dpkg -i /tmp/codecserver-driver-softmbe_0.0.1_*.deb

rm -f /tmp/libmbe* /tmp/codecserver-driver-softmbe*

cat >> /etc/codecserver/codecserver.conf << _EOF_

# add softmbe
[device:softmbe]
driver=softmbe
_EOF_


systemctl restart codecserver.service
systemctl restart openwebrx.service
echo;echo;echo
echo "Installation successful. OpenWebRX+ has been restarted."

popd
