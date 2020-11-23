#!/bin/bash -e
## Build Mixxx
mkdir -p ${BASE_DIR}/.ccache/
mkdir -p "${ROOTFS_DIR}/ccache"
mount --bind ${BASE_DIR}/.ccache  "${ROOTFS_DIR}/ccache"
on_chroot << EOF
    git clone https://github.com/mixxxdj/mixxx.git /code/
    cd /code/ && git checkout 2.3 && git pull
    export CCACHE_DIR=/ccache
    ccache -M 5G
    export CCACHE_NOCOMPRESS="true"
    export CTEST_PARALLEL_LEVEL="$(nproc)"
    export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
    export PATH="$HOME/.local/bin:$PATH"
    export CMAKEFLAGS="-DCMAKE_BUILD_TYPE=Release -DBATTERY=ON -DBROADCAST=ON -DBULK=ON -DDEBUG_ASSERTIONS_FATAL=ON -DHID=ON -DLILV=ON -DOPUS=ON -DQTKEYCHAIN=ON -DVINYLCONTROL=ON -DENGINEPRIME=ON"
    export CMAKEFLAGS_EXTRA="-DFAAD=ON -DKEYFINDER=ON -DLOCALECOMPARE=ON -DMAD=ON -DMODPLUG=ON -DWAVPACK=ON -DWARNINGS_FATAL=ON"
    export GTEST_COLOR="1"
    export CTEST_OUTPUT_ON_FAILURE="1"
    export QT_QPA_PLATFORM="offscreen"
    mkdir -p cmake_build && cd cmake_build
    cmake -DCMAKE_INSTALL_PREFIX=/usr .. 
    cmake -L $CMAKEFLAGS $CMAKEFLAGS_EXTRA ..
    cmake --build . --target install
    ccache -s
    cpack -G DEB
EOF

unmount "${BASE_DIR}/.ccache"
cp ${ROOTFS_DIR}/code/cmake_build/*.deb "$DEPLOY_DIR"
