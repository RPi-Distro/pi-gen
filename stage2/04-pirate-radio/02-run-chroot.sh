#!/bin/bash -e

systemctl enable pulseaudio

cd /root/pivumeter
aclocal && libtoolize
autoconf && automake --add-missing
./configure && make
make install
