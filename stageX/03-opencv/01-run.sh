#!/bin/bash -e

# Note: Setting versions because of https://github.com/EdjeElectronics/TensorFlow-Object-Detection-on-the-Raspberry-Pi/issues/67
on_chroot << EOF
apt install --reinstall -yqq python-pip python3-pip
pip install wheel

# For Python3 
pip3 install wheel
pip3 install opencv-python==3.4.6.27

if [ ! -r /dev/raw1394 ]; then
	sudo ln /dev/null /dev/raw1394
fi
EOF
