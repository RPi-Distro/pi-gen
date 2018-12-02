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
cp ../thirdparty-opencv/arm-pi-gnueabihf.toolchain.cmake .
cp -R ../thirdparty-opencv/jni .

popd
