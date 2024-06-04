#!/bin/bash
set -euxo pipefail

BUILD_PACKAGES="git build-essential debhelper cmake libprotobuf-dev protobuf-compiler"

apt update
apt -y install --no-install-recommends $BUILD_PACKAGES libcodecserver-dev


pushd /tmp

echo "+ Build MBELIB..."
git clone https://github.com/szechyjs/mbelib.git
cd mbelib
dpkg-buildpackage
cd ..
rm -rf mbelib
dpkg -i libmbe1_1.3.0_*.deb libmbe-dev_1.3.0_*.deb

echo "+ Build codecserver-softmbe..."
git clone https://github.com/knatterfunker/codecserver-softmbe.git
cd codecserver-softmbe
# ignore missing library linking error in dpkg-buildpackage command
sed -i 's/dh \$@/dh \$@ --dpkg-shlibdeps-params=--ignore-missing-info/' debian/rules
dpkg-buildpackage
cd ..
rm -rf codecserver-softmbe

apt remove -y --purge --autoremove $BUILD_PACKAGES

dpkg -i /tmp/libmbe1_1.3.0_*.deb
dpkg -i /tmp/codecserver-driver-softmbe_0.0.1_*.deb

rm -f /tmp/libmbe* /tmp/codecserver-driver-softmbe*

cat >> /etc/codecserver/codecserver.conf << _EOF_

# add softmbe
[device:softmbe]
driver=softmbe
_EOF_


echo;echo;echo
echo "Installation successful. Please reboot."

popd
