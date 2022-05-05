#!/bin/bash
(cd /tmp
git clone https://github.com/rauc/rauc.git
cd rauc
git checkout master
git pull
git checkout v1.6
./autogen.sh
./configure --prefix=/usr --enable-streaming
make -j4
export DESTDIR="/tmp/pionix-rauc" && make -j4 install)
mkdir -p /tmp/pionix-rauc/DEBIAN
cp control /tmp/pionix-rauc/DEBIAN
dpkg-deb --build --root-owner-group /tmp/pionix-rauc

