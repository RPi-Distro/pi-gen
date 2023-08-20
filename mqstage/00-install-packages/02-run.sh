#!/bin/bash
on_chroot << EOF
python3 -m pip install --upgrade pip
pip install --only-binary :all: opencv-python
python3 -m pip install tflite-runtime
EOF
