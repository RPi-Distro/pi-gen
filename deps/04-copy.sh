#!/bin/sh

DEST=${PWD}/../stage2/01-sys-tweaks/extfiles

mkdir -p ${DEST}

#
# examples
#
mkdir -p examples/java-multiCameraServer/src/main/java
cp allwpilib/cameraserver/multiCameraServer/src/main/java/Main.java examples/java-multiCameraServer/src/main/java/
cp allwpilib/cameraserver/multiCameraServer/src/main/native/cpp/main.cpp examples/cpp-multiCameraServer/

sh -c 'cd examples && zip -r - java-multiCameraServer' > ${DEST}/java-multiCameraServer.zip
sh -c 'cd examples && zip -r - cpp-multiCameraServer' > ${DEST}/cpp-multiCameraServer.zip
sh -c 'cd examples && zip -r - python-multiCameraServer' > ${DEST}/python-multiCameraServer.zip

#
# tools
#

cp tools/setuidgids ${DEST}/
cp tools/_cscore.so ${DEST}/_cscore.cpython-35m-arm-linux-gnueabihf.so
cp tools/rpiConfigServer ${DEST}/

#
# openjdk
#

cp 01-download/jdk_11.0.1-strip.tar.gz ${DEST}/

#
# thirdparty-opencv
#

sh -c 'cd 03-build/opencv-build/install/lib && tar czf - libopencv*' > ${DEST}/libopencv.tar.gz

sh -c 'cd 03-build/opencv-build/install/include && tar czf - .' > ${DEST}/opencv-include.tar.gz

cp 03-build/opencv-build/install/share/OpenCV/java/opencv-*.jar ${DEST}/

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

cp \
  allwpilib/wpiutil/build/libs/wpiutil/shared/release/libwpiutil.so* \
  allwpilib/wpiutil/build/libs/wpiutil/shared/debug/libwpiutild.so* \
  allwpilib/wpiutil/build/libs/wpiutil.jar \
  allwpilib/cscore/build/libs/cscore/shared/release/libcscore.so* \
  allwpilib/cscore/build/libs/cscore/shared/debug/libcscored.so* \
  allwpilib/cscore/build/libs/cscoreJNIShared/shared/release/libcscorejni.so* \
  allwpilib/cscore/build/libs/cscore.jar \
  allwpilib/ntcore/build/libs/ntcore/shared/release/libntcore.so* \
  allwpilib/ntcore/build/libs/ntcore/shared/debug/libntcored.so* \
  allwpilib/ntcore/build/libs/ntcoreJNIShared/shared/release/libntcorejni.so* \
  allwpilib/ntcore/build/libs/ntcore.jar \
  allwpilib/cameraserver/build/libs/cameraserver/shared/release/libcameraserver.so* \
  allwpilib/cameraserver/build/libs/cameraserver/shared/debug/libcameraserverd.so* \
  allwpilib/cameraserver/build/libs/cameraserver.jar \
  ${DEST}/

sh -c 'cd allwpilib/wpiutil/src/main/native/include && tar czf - uv.h uv wpi' > ${DEST}/wpiutil-include.tar.gz
sh -c 'cd allwpilib/cscore/src/main/native/include && tar czf - .' > ${DEST}/cscore-include.tar.gz
sh -c 'cd allwpilib/ntcore/src/main/native/include && tar czf - .' > ${DEST}/ntcore-include.tar.gz
sh -c 'cd allwpilib/cameraserver/src/main/native/include && tar czf - cameraserver vision' > ${DEST}/cameraserver-include.tar.gz

cp \
  allwpilib/cameraserver/multiCameraServer/build/exe/multiCameraServerCpp/multiCameraServerCpp \
  ${DEST}/multiCameraServer

cp \
  allwpilib/wpiutil/build/exe/netconsoleTee/netconsoleTee \
  ${DEST}/
