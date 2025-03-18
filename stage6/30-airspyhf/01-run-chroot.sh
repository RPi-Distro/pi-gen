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


# fix airspy mini and airspy hf permissions
cat >> /etc/udev/rules.d/52-airspy.rules << __EOF__
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1d50",ATTRS{idProduct}=="60a1",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="03eb",ATTRS{idProduct}=="800c",MODE:="0666"
__EOF__

rm -rf airspyhf SoapyAirspyHF

popd
