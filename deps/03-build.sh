#!/bin/bash

export PATH=${PWD}/02-extract/raspbian9/bin:${PATH}

# opencv
mkdir -p 03-build/opencv-build
pushd 03-build/opencv-build
cmake ../../02-extract/opencv \
    -DWITH_CUDA=OFF \
    -DWITH_IPP=OFF \
    -DWITH_ITT=OFF \
    -DWITH_OPENCL=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_OPENEXR=OFF \
    -DWITH_GSTREAMER=OFF \
    -DWITH_LAPACK=OFF \
    -DWITH_GTK=ON \
    -DWITH_1394=OFF \
    -DWITH_JASPER=OFF \
    -DWITH_TIFF=OFF \
    -DBUILD_JPEG=ON \
    -DBUILD_PNG=ON \
    -DBUILD_ZLIB=ON \
    -DBUILD_TESTS=OFF \
    -DPython_ADDITIONAL_VERSIONS=3.5 \
    -DWITH_WEBP=OFF \
    -DBUILD_JAVA=ON \
    -DBUILD_WITH_STATIC_CRT=OFF \
    -DWITH_PROTOBUF=OFF \
    -DWITH_DIRECTX=OFF \
    -DENABLE_CXX11=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=${PWD}/../../02-extract/arm-pi-gnueabihf.toolchain.cmake \
    -DCMAKE_MAKE_PROGRAM=make \
    -DENABLE_NEON=ON \
    -DENABLE_VFPV3=ON \
    -DBUILD_opencv_python3=ON \
    -DPYTHON3_INCLUDE_PATH=${PWD}/../../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf/usr/include/python3.5m \
    -DPYTHON3_NUMPY_INCLUDE_DIRS=${PWD}/../../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf/usr/include/python3.5m/numpy \
    -DOPENCV_EXTRA_FLAGS_DEBUG=-Og \
    -DCMAKE_MODULE_PATH=${PWD}/../../thirdparty-opencv/arm-frc-modules \
    || exit 1
make -j3 || exit 1
make install || exit 1

popd

# wpiutil, cscore, ntcore, cameraserver
pushd allwpilib
./gradlew -PonlyRaspbian :wpiutil:build :cscore:build :ntcore:build :cameraserver:build :cameraserver:multiCameraServer:build || exit 1
popd

# tools
pushd tools
make || exit 1
popd
