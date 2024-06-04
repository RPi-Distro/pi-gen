#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/drowe67/codec2.git
cmakebuild codec2
install -m 0755 codec2/build/src/freedv_rx /usr/local/bin
ldconfig

rm -rf codec2

popd
