#!/bin/sh

DEST=${PWD}/../stage2/01-sys-tweaks/extfiles

mkdir -p ${DEST}

#
# examples
#

sh -c 'cd examples && zip -r - java-multiCameraServer' > ${DEST}/java-multiCameraServer.zip
sh -c 'cd examples && zip -r - cpp-multiCameraServer' > ${DEST}/cpp-multiCameraServer.zip
sh -c 'cd examples && zip -r - python-multiCameraServer' > ${DEST}/python-multiCameraServer.zip

#
# tools
#

cp tools/setuidgids ${DEST}/
cp tools/_cscore.so ${DEST}/_cscore.cpython-35m-arm-linux-gnueabihf.so
cp tools/_cscore.so.debug ${DEST}/
cp tools/multiCameraServer ${DEST}/
cp tools/multiCameraServer.debug ${DEST}/
cp tools/rpiConfigServer ${DEST}/
cp tools/rpiConfigServer.debug ${DEST}/

#
# openjdk
#

cp 01-download/jdk_11.0.1-strip.tar.gz ${DEST}/

#
# opencv
#

sh -c 'cd 03-build/opencv-build/install/lib && tar czf - libopencv*' > ${DEST}/libopencv.tar.gz
sh -c 'cd 03-build/opencv-build-debug/install/lib && tar czf - libopencv*' > ${DEST}/libopencv-debug.tar.gz

sh -c 'cd 03-build/opencv-build/install/include && tar czf - .' > ${DEST}/opencv-include.tar.gz

cp 03-build/opencv-build/install/share/OpenCV/java/opencv-*.jar ${DEST}/

sh -c 'cd 03-build/opencv-build/install/share/OpenCV && tar czf - *.cmake' > ${DEST}/opencv-cmake.tar.gz
sh -c 'cd 03-build/opencv-build-debug/install/share/OpenCV && tar czf - *.cmake' > ${DEST}/opencv-cmake-debug.tar.gz

# the opencv build names the python .so with the build platform name instead
# of the target platform, so rename it
cp 03-build/opencv-build/install/python/cv2/python-*/cv2.*.so ${DEST}/cv2.cpython-35m-arm-linux-gnueabihf.so

#
# robotpy-cscore
#

sh -c 'cd robotpy-cscore && tar czf - cscore' > ${DEST}/robotpy-cscore.tar.gz

#
# pynetworktables
#

sh -c 'cd pynetworktables && tar czf - networktables ntcore' > ${DEST}/pynetworktables.tar.gz

#
# allwpilib
#

sh -c 'cd 03-build/allwpilib-build/lib && tar czf - lib*' > ${DEST}/wpilib.tar.gz
sh -c 'cd 03-build/allwpilib-build-debug/lib && tar czf - lib*' > ${DEST}/wpilib-debug.tar.gz
sh -c 'cd 03-build/allwpilib-build/hal/gen && tar czf - .' > ${DEST}/hal-gen-include.tar.gz

cp 03-build/allwpilib-build/jar/*.jar ${DEST}/

sh -c 'cd allwpilib/wpiutil/src/main/native/include && tar czf - uv.h uv wpi' > ${DEST}/wpiutil-include.tar.gz
sh -c 'cd allwpilib/cscore/src/main/native/include && tar czf - .' > ${DEST}/cscore-include.tar.gz
sh -c 'cd allwpilib/ntcore/src/main/native/include && tar czf - .' > ${DEST}/ntcore-include.tar.gz
sh -c 'cd allwpilib/cameraserver/src/main/native/include && tar czf - cameraserver vision' > ${DEST}/cameraserver-include.tar.gz
sh -c 'cd allwpilib/hal/src/main/native/include && tar czf - .' > ${DEST}/hal-include.tar.gz
sh -c 'cd allwpilib/wpilibc/src/main/native/include && tar czf - frc' > ${DEST}/wpilibc-include.tar.gz

sh -c 'cd 03-build/allwpilib-static/bin && tar czf - cscore_* netconsoleTee*' > ${DEST}/wpilib-bin.tar.gz
