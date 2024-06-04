#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/pa3gsb/Radioberry-2.x
pushd Radioberry-2.x/SBC/rpi-4
cmakebuild SoapyRadioberrySDR
popd
ldconfig
rm -rf Radioberry-2.x

popd
