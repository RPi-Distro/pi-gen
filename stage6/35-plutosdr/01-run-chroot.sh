#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone --depth 1 https://github.com/pothosware/SoapyPlutoSDR.git
cmakebuild SoapyPlutoSDR
ldconfig

rm -rf SoapyPlutoSDR

popd
