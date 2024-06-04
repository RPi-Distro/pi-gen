#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

git clone --depth 1 https://github.com/airspy/airspyhf.git
cmakebuild airspyhf master -DINSTALL_UDEV_RULES=ON
ldconfig

git clone https://github.com/pothosware/SoapyAirspyHF.git
#cmakebuild SoapyAirspyHF df64188dd36bc0be4db623726a4aad89c775d937
cmakebuild SoapyAirspyHF
ldconfig

rm -rf airspyhf SoapyAirspyHF

popd
