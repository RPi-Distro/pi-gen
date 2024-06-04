#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/0xAF/rockprog-linux
pushd rockprog-linux
make
cp rockprog /usr/local/bin/
popd
rm -rf rockprog-linux

popd

