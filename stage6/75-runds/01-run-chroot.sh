#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

# we cannot build deb package from this, before owrx-connector becomes 0.7 (it's 0.6.2 ATM)

git clone https://github.com/jketterl/runds_connector
cmakebuild runds_connector master
ldconfig

rm -rf runds_connector

popd
