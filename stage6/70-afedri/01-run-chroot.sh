#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/alexander-sholohov/SoapyAfedri
cmakebuild SoapyAfedri
ldconfig

rm -rf SoapyAfedri

popd
