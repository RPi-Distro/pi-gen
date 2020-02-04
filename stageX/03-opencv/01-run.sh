#!/bin/bash -e

# Note: Setting versions because of https://github.com/EdjeElectronics/TensorFlow-Object-Detection-on-the-Raspberry-Pi/issues/67
on_chroot << EOF
# Installing for Python 2.7
pip2 install numpy>=1.16.2
pip2 install opencv-python==3.4.6.27
pip2 install python-scipy
pip2 install wheel
pip2 install picamera

# For Python3 
pip3 install numpy>=1.16.2
pip3 install opencv-python==3.4.6.27
pip3 install python-scipy
pip3 install wheel
pip3 install picamera

if [ ! -r /dev/raw1394 ]; then
	sudo ln /dev/null /dev/raw1394
fi
EOF
