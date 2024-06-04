#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone https://github.com/rtlsdrblog/rtl-sdr-blog
pushd rtl-sdr-blog
dpkg-buildpackage -b --no-sign
popd

rm -rf rtl-sdr-blog

dpkg -i librtlsdr0_*.deb
#dpkg -i librtlsdr-dev_*.deb
dpkg -i rtl-sdr_*.deb

popd
