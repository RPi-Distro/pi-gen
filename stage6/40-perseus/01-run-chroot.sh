#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/Microtelecom/libperseus-sdr.git
pushd libperseus-sdr
git checkout v0.8.2
./bootstrap.sh
./configure
make
make install
ldconfig
popd
rm -rf libperseus-sdr

popd

usermod -a -G perseususb pi

