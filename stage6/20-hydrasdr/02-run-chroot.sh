#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/hydrasdr/rfone_host
cmakebuild rfone_host
rm -rf rfone_host

git clone https://github.com/hydrasdr/SoapyHydraSDR
cmakebuild SoapyHydraSDR
rm -rf SoapyHydraSDR

popd
