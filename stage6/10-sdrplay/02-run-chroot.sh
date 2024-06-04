#!/usr/bin/env bash
set -euo pipefail

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
source /tmp/cmake_helper.sh

pushd /tmp

mkdir SDRPlay
pushd SDRPlay

case `uname -m` in
	arm*)
		echo;echo ":::   ARMv7 32bit"
		BINARY=SDRplay_RSP_API-ARM32-3.07.2.run
		;;
	*)
		echo;echo ":::   64bit"
		BINARY=SDRplay_RSP_API-Linux-3.15.1.run
		;;
esac

wget http://www.sdrplay.com/software/$BINARY
sh $BINARY --noexec --target sdrplay
patch --verbose -Np0 < /tmp/$BINARY.patch

pushd sdrplay
./install_lib.sh
popd # back to SDRPlay

popd # back to /tmp
rm -rf SDRPlay

systemctl daemon-reload
systemctl enable sdrplay

popd

