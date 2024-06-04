#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

# remove the old driver
apt remove -y --autoremove --purge soapysdr0.8-module-mirisdr

pushd /tmp

git clone https://github.com/ericek111/libmirisdr-5
cmakebuild libmirisdr-5
ldconfig

git clone https://github.com/ericek111/SoapyMiri
cmakebuild SoapyMiri
ldconfig

rm -rf libmirisdr-5 SoapyMiri

popd
