#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/alexander-sholohov/msk144decoder.git
# this will fail with multiple jobs compiling
MAKEFLAGS= cmakebuild msk144decoder
ldconfig

rm -rf msk144decoder

popd
