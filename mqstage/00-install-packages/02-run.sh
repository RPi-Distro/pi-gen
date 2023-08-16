#!/bin/bash -e
on_chroot << EOF
python3 -m pip install tflite-runtime
python3 -m pip install opencv-python
EOF