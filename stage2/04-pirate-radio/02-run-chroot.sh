#!/bin/bash -e

# pulseaudio
systemctl enable pulseaudio

#pivumeter
cd /root/pivumeter
aclocal && libtoolize
autoconf && automake --add-missing
./configure && make
make install

# mpd
cd /root/python-mpd2
python3 setup.py install

# physical interface
useradd -r -s /bin/false radio-interface
adduser radio-interface gpio
echo 'radio-interface ALL=(ALL) NOPASSWD: /sbin/shutdown' > /etc/sudoers.d/010_radio-interface-shutdown
chmod 0440 /etc/sudoers.d/010_radio-interface-shutdown
systemctl enable radio-interface

# web interface
cd /root/ympd
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr
make
make install
systemctl enable ympd
