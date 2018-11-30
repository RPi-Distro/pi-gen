#!/bin/sh

mkdir -p stage2/01-sys-tweaks/extfiles

#
# openjdk
#
cp ../raspbian-openjdk/jdk_11.0.1-strip.tar.gz stage2/01-sys-tweaks/extfiles/

#
# thirdparty-opencv
#

sh -c 'cd ../thirdparty-opencv/buildShared/linux-raspbian/lib && tar czf - libopencv*' > stage2/01-sys-tweaks/extfiles/libopencv.tar.gz

cp ../thirdparty-opencv/buildShared/linux-raspbian/bin/opencv-*.jar stage2/01-sys-tweaks/extfiles/

# the opencv build names the python .so with the build platform name instead
# of the target platform, so rename it
cp ../thirdparty-opencv/buildShared/linux-raspbian/lib/python3/cv2.*.so stage2/01-sys-tweaks/extfiles/cv2.cpython-35m-arm-linux-gnueabihf.so

#
# allwpilib
#

cp \
  ../allwpilib/wpiutil/build/libs/wpiutil/shared/raspbian/release/libwpiutil.so* \
  ../allwpilib/wpiutil/build/libs/wpiutil/shared/raspbian/debug/libwpiutild.so* \
  ../allwpilib/wpiutil/build/libs/wpiutil.jar \
  ../allwpilib/cscore/build/libs/cscore/shared/raspbian/release/libcscore.so* \
  ../allwpilib/cscore/build/libs/cscore/shared/raspbian/debug/libcscored.so* \
  ../allwpilib/cscore/build/libs/cscoreJNIShared/shared/raspbian/release/libcscorejni.so* \
  ../allwpilib/cscore/build/libs/cscore.jar \
  ../allwpilib/ntcore/build/libs/ntcore/shared/raspbian/release/libntcore.so* \
  ../allwpilib/ntcore/build/libs/ntcore/shared/raspbian/debug/libntcored.so* \
  ../allwpilib/ntcore/build/libs/ntcoreJNIShared/shared/raspbian/release/libntcorejni.so* \
  ../allwpilib/ntcore/build/libs/ntcore.jar \
  ../allwpilib/cameraserver/build/libs/cameraserver/shared/raspbian/release/libcameraserver.so* \
  ../allwpilib/cameraserver/build/libs/cameraserver/shared/raspbian/debug/libcameraserverd.so* \
  ../allwpilib/cameraserver/build/libs/cameraserver.jar \
  stage2/01-sys-tweaks/extfiles/

sh -c 'cd ../allwpilib/wpiutil/src/main/native/include && tar czf - uv.h uv wpi' > stage2/01-sys-tweaks/extfiles/wpiutil-include.tar.gz
sh -c 'cd ../allwpilib/cscore/src/main/native/include && tar czf - .' > stage2/01-sys-tweaks/extfiles/cscore-include.tar.gz
sh -c 'cd ../allwpilib/ntcore/src/main/native/include && tar czf - .' > stage2/01-sys-tweaks/extfiles/ntcore-include.tar.gz
sh -c 'cd ../allwpilib/cameraserver/src/main/native/include && tar czf - cameraserver vision' > stage2/01-sys-tweaks/extfiles/cameraserver-include.tar.gz

cp \
  ../allwpilib/cameraserver/build/exe/multiCameraServer/raspbian/multiCameraServer \
  ../allwpilib/wpiutil/build/exe/netconsoleServer/raspbian/netconsoleServer \
  ../allwpilib/wpiutil/build/exe/rpiConfigServer/raspbian/rpiConfigServer \
  stage2/01-sys-tweaks/extfiles/
