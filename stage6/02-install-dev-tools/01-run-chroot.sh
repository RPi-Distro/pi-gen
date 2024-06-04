#!/usr/bin/env bash
set -euo pipefail

echo;echo "::: Compiling with MAKEFLAGS=$MAKEFLAGS";echo

# cmakebuild <folder> [git_tag|git_commit] [-DCMAKE_FLAG=YES ...]
#source /tmp/cmake_helper.sh

cat > /tmp/cmake_helper.sh << _EOF_
function cmakebuild() {
	pushd \$1
	if [[ ! -z "\${2:-}" ]]; then
		git checkout \$2
	fi
	if [[ -f ".gitmodules" ]]; then
		git submodule update --init
	fi
	rm -rf build
	mkdir build
	pushd build
	cmake \${@:3} ..
	make
	make install
	popd
	popd
}
_EOF_

