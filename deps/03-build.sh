#!/bin/bash

export PATH=${PWD}/02-extract/raspbian9/bin:${PATH}

split_debug () {
    arm-raspbian9-linux-gnueabihf-objcopy --only-keep-debug $1 $1.debug
    arm-raspbian9-linux-gnueabihf-strip -g $1
    arm-raspbian9-linux-gnueabihf-objcopy --add-gnu-debuglink=$1.debug $1
}

split_debug_so () {
    pushd $1
    for lib in *.so
    do
        split_debug $lib
    done
    popd
}

split_debug_exe () {
    pushd $1
    for exe in *
    do
        split_debug $exe
    done
    popd
}

# opencv
build_opencv () {
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
        -DBUILD_JAVA=$2 \
        -DBUILD_WITH_STATIC_CRT=OFF \
        -DWITH_PROTOBUF=OFF \
        -DWITH_DIRECTX=OFF \
        -DENABLE_CXX11=ON \
        -DBUILD_SHARED_LIBS=$2 \
        -DCMAKE_BUILD_TYPE=$1 \
        -DCMAKE_DEBUG_POSTFIX=d \
        -DCMAKE_TOOLCHAIN_FILE=${PWD}/../../02-extract/arm-pi-gnueabihf.toolchain.cmake \
        -DCMAKE_MAKE_PROGRAM=make \
        -DENABLE_NEON=ON \
        -DENABLE_VFPV3=ON \
        -DBUILD_opencv_python3=$2 \
        -DPYTHON3_INCLUDE_PATH=${PWD}/../../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf/usr/include/python3.5m \
        -DPYTHON3_NUMPY_INCLUDE_DIRS=${PWD}/../../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf/usr/include/python3.5m/numpy \
        -DOPENCV_EXTRA_FLAGS_DEBUG=-Og \
        -DCMAKE_MODULE_PATH=${PWD}/../../02-extract/cmake-modules \
        || exit 1
    make -j3 || exit 1
    make install || exit 1
    if [ "$1" == "RelWithDebugInfo" ]
    then
        cp -p install/share/OpenCV/java/libopencv_java*.so install/lib/
    fi
    split_debug_so install/lib
}

mkdir -p 03-build/opencv-build
pushd 03-build/opencv-build
build_opencv RelWithDebugInfo ON || exit 1
popd

mkdir -p 03-build/opencv-build-debug
pushd 03-build/opencv-build-debug
build_opencv Debug ON || exit 1
popd

mkdir -p 03-build/opencv-static
pushd 03-build/opencv-static
build_opencv RelWithDebugInfo OFF || exit 1
popd

# wpiutil, cscore, ntcore, cameraserver
# always use the release version of opencv jar/jni
build_wpilib () {
    cmake ../../allwpilib \
	-DWITHOUT_ALLWPILIB=OFF \
        -DCMAKE_BUILD_TYPE=$1 \
        -DCMAKE_TOOLCHAIN_FILE=${PWD}/../../02-extract/arm-pi-gnueabihf.toolchain.cmake \
        -DCMAKE_MODULE_PATH=${PWD}/../../02-extract/cmake-modules \
        -DOPENCV_JAR_FILE=`ls ${PWD}/../opencv-build/install/share/OpenCV/java/opencv-*.jar` \
        -DOPENCV_JNI_FILE=`ls ${PWD}/../opencv-build/install/share/OpenCV/java/libopencv_java*.so` \
        -DOpenCV_DIR=${PWD}/../$2/install/share/OpenCV \
        -DTHREADS_PTHREAD_ARG=-pthread \
        || exit 1
    make -j3 || exit 1
    split_debug_so lib
}

mkdir -p 03-build/allwpilib-build
pushd 03-build/allwpilib-build
build_wpilib RelWithDebugInfo opencv-build || exit 1
popd

mkdir -p 03-build/allwpilib-build-debug
pushd 03-build/allwpilib-build-debug
build_wpilib Debug opencv-build-debug || exit 1
popd

# static (for tools)
mkdir -p 03-build/allwpilib-static
pushd 03-build/allwpilib-static
cmake ../../allwpilib \
    -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DCMAKE_TOOLCHAIN_FILE=${PWD}/../../02-extract/arm-pi-gnueabihf.toolchain.cmake \
    -DCMAKE_MODULE_PATH=${PWD}/../../02-extract/cmake-modules \
    -DOpenCV_DIR=${PWD}/../opencv-static/install/share/OpenCV \
    -DWITHOUT_JAVA=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DTHREADS_PTHREAD_ARG=-pthread \
    || exit 1
make -j3 || exit 1
split_debug_exe bin
popd

# tools
pushd tools
make || exit 1
popd
