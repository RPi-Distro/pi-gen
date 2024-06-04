#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/altillimity/satdump.git
cmakebuild satdump master -DBUILD_GUI=OFF -DBUILD_OPENCL=OFF
ldconfig

rm -rf satdump

popd
