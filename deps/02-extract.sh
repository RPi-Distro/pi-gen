#!/bin/bash

mkdir -p 02-extract
pushd 02-extract

# raspbian toolchain
tar xzf ../01-download/Raspbian9-Linux-Toolchain-*.tar.gz

# additional headers/libs
pushd raspbian9/arm-raspbian9-linux-gnueabihf

# Extract data to toolchain basedir
for var in ../../../01-download/*.deb
do
ar p "$var" data.tar.xz | tar xJf -
done

# move the arm-linux-gnueabihf libs to just the base "lib"
sh -c 'cd lib && ln -s arm-linux-gnueabihf/* .'
sh -c 'cd usr/lib/debug && ln -s ../arm-linux-gnueabihf/debug/* .'
sh -c 'cd usr/lib && ln -s arm-linux-gnueabihf/* .'

# change absolute symlinks into relative symlinks
find . -lname '/*' | \
while read l ; do
  echo ln -sf $(echo $(echo $l | sed 's|/[^/]*|/..|g')$(readlink $l) | sed 's/.....//') $l
done | \
sh

popd

# opencv sources
tar xzf ../01-download/3.4.4.tar.gz
mv opencv-3.4.4 opencv
sed -i -e 's/javac sourcepath/javac target="1.8" source="1.8" sourcepath/' opencv/modules/java/jar/build.xml.in
# disable extraneous data warnings; these are common with USB cameras
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' opencv/3rdparty/libjpeg/jdmarker.c
sed -i -e '/JWRN_EXTRANEOUS_DATA/d' opencv/3rdparty/libjpeg-turbo/src/jdmarker.c

# toolchain setup for opencv and wpilib
cp ../arm-pi-gnueabihf.toolchain.cmake .
tar xzf ../01-download/jdk_11*.tar.gz jdk/include
mkdir -p cmake-modules
cat > cmake-modules/FindJNI.cmake << EOF
set(JNI_INCLUDE_DIRS "${PWD}/jdk/include" "${PWD}/jdk/include/linux")
set(JNI_LIBRARIES )
set(JNI_FOUND YES)
set(JAVA_AWT_LIBRARY )
set(JAVA_JVM_LIBRARY )
set(JAVA_INCLUDE_PATH "${PWD}/jdk/include")
set(JAVA_INCLUDE_PATH2 "${PWD}/jdk/include/linux")
set(JAVA_AWT_INCLUDE_PATH )
EOF

popd
