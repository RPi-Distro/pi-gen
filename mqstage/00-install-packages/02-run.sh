#!/bin/bash
on_chroot << EOF
python3 -m pip install --upgrade pip
pip install --only-binary :all: opencv-python
python3 -m pip install 'https://www.piwheels.org/simple/numpy/numpy-1.25.2-cp39-cp39-linux_armv7l.whl'
pip install tflite-runtime
EOF
