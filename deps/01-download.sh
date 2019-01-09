#!/bin/bash

mkdir -p 01-download
pushd 01-download

# raspbian toolchain
wget -nc -nv \
    https://github.com/wpilibsuite/raspbian-toolchain/releases/download/v1.2.0/Raspbian9-Linux-Toolchain-6.3.0.tar.gz

# openjdk binaries
wget -nc -nv \
    https://github.com/wpilibsuite/raspbian-openjdk/releases/download/v2019-11.0.1-1/jdk_11.0.1-strip.tar.gz

# python headers/libs
wget -nc -nv \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/libpython3.5_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/libpython3.5-dev_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/libpython3.5-minimal_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/python3.5-dev_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/python3.5-minimal_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python3.5/python3.5_3.5.3-1+deb9u1_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/python-numpy/python3-numpy_1.12.1-3_armhf.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/pybind11/python3-pybind11_2.2.4-2_all.deb \
    http://archive.raspbian.org/raspbian/pool/main/p/pybind11/pybind11-dev_2.2.4-2_all.deb

# opencv sources
wget -nc -nv \
    https://github.com/opencv/opencv/archive/3.4.4.tar.gz

popd
