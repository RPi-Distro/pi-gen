#!/usr/bin/env bash
set -euxo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone --depth 1 https://github.com/pothosware/SoapyPlutoSDR.git
echo;echo;echo;echo;echo
echo $MAKEFLAGS
echo;echo;echo;echo;echo
cmakebuild SoapyPlutoSDR
ldconfig

rm -rf SoapyPlutoSDR

popd
