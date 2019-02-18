#!/bin/bash -e

SUB_STAGE_DIR=${PWD}

# enable pi camera
install -m 644 files/picamera.conf	"${ROOTFS_DIR}/etc/modules-load.d/"

install -m 644 files/frc.json "${ROOTFS_DIR}/boot/"

#
# Install tools sources
# install to both image and work directory (to build)
#
sh -c "cd ${BASE_DIR}/deps/tools && tar cf - ." | \
    sh -c "cd ${ROOTFS_DIR}/usr/src && tar xf -"
sh -c "cd ${BASE_DIR}/deps && tar cf - tools" | \
    sh -c "cd ${STAGE_WORK_DIR} && tar xf -"

#
# Build tools
#
export PATH=${WORK_DIR}/raspbian9/bin:${PATH}

pushd "${STAGE_WORK_DIR}/tools"

export CXXFLAGS="--sysroot=${ROOTFS_DIR} -Wl,-rpath -Wl,${ROOTFS_DIR}/opt/vc/lib"
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=${ROOTFS_DIR}/usr/lib/arm-linux-gnueabihf/pkgconfig:${ROOTFS_DIR}/usr/lib/pkgconfig:${ROOTFS_DIR}/usr/share/pkgconfig:${ROOTFS_DIR}/usr/local/frc-static/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${ROOTFS_DIR}

# setuidgids
pushd setuidgids
make CC=arm-raspbian9-linux-gnueabihf-gcc
install -m 755 setuidgids "${ROOTFS_DIR}/usr/local/bin/"

popd

# multiCameraServer
pushd multiCameraServer
make CXX=arm-raspbian9-linux-gnueabihf-g++
install -m 755 multiCameraServer "${ROOTFS_DIR}/usr/local/frc/bin/"

popd

# configServer
pushd configServer
make CXX=arm-raspbian9-linux-gnueabihf-g++
install -m 755 configServer "${ROOTFS_DIR}/usr/local/sbin/"

popd

popd

#
# Examples
# install to both image and work directory (to build zips)
#
export PKG_CONFIG_LIBDIR=${ROOTFS_DIR}/usr/lib/arm-linux-gnueabihf/pkgconfig:${ROOTFS_DIR}/usr/lib/pkgconfig:${ROOTFS_DIR}/usr/share/pkgconfig:${ROOTFS_DIR}/usr/local/frc/lib/pkgconfig

sh -c "cd ${BASE_DIR}/deps && tar cf - examples" | \
    sh -c "cd ${ROOTFS_DIR}/home/pi && tar xf -"
for dir in ${ROOTFS_DIR}/home/pi/examples/*; do
    cp "${BASE_DIR}/LICENSE.txt" "${dir}/"
done
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/examples"

rm -rf "${STAGE_WORK_DIR}/examples"
sh -c "cd ${BASE_DIR}/deps && tar cf - examples" | \
    sh -c "cd ${STAGE_WORK_DIR} && tar xf -"
for dir in ${STAGE_WORK_DIR}/examples/*; do
    cp "${BASE_DIR}/LICENSE.txt" "${dir}/"
done

# build zips
pushd "${STAGE_WORK_DIR}/examples"

# add jar dependencies to java-multiCameraServer
sh -c "cd ${ROOTFS_DIR}/usr/local/frc/java && tar cf - *.jar" | \
    sh -c "cd java-multiCameraServer && tar xf -"

# add header and library dependencies (excluding .debug files) to
# cpp-multiCameraServer
sh -c "cd ${ROOTFS_DIR}/usr/local/frc && tar cf - include" | \
    sh -c "cd cpp-multiCameraServer && tar xf -"
mkdir -p cpp-multiCameraServer/lib
LIBS=`pkg-config --libs wpilibc | sed -e "s,-L[^ ]*,,g;s,-l\\([^ ]*\\),${ROOTFS_DIR}/usr/local/frc/lib/lib\\1.so,g"`
for lib in ${LIBS}; do
    ln -sf ${lib} cpp-multiCameraServer/lib/
done

# update Makefile to use cross-compiler and point to local dependencies
cat > cpp-multiCameraServer/Makefile.new << EOF
CXX=arm-raspbian9-linux-gnueabihf-g++
DEPS_CFLAGS=`pkg-config --cflags wpilibc | sed -e "s,${ROOTFS_DIR}/usr/local/frc/,,g"`
DEPS_LIBS=`pkg-config --libs wpilibc | sed -e "s,${ROOTFS_DIR}/usr/local/frc/,,g"`
EOF
sed -e '/^DEPS_/d' cpp-multiCameraServer/Makefile >> cpp-multiCameraServer/Makefile.new
mv cpp-multiCameraServer/Makefile.new cpp-multiCameraServer/Makefile

# add windows make executable
cp "${SUB_STAGE_DIR}/files/make.exe" cpp-multiCameraServer/

zip -r java-multiCameraServer.zip java-multiCameraServer
zip -r cpp-multiCameraServer.zip cpp-multiCameraServer
zip -r python-multiCameraServer.zip python-multiCameraServer

# install zips
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/zips/"
install -v -o 1000 -g 1000 *.zip "${ROOTFS_DIR}/home/pi/zips/"

popd

#
# Set up services
#

# configServer
install -v -d "${ROOTFS_DIR}/service/configServer"
install -m 755 files/configServer_run "${ROOTFS_DIR}/service/configServer/run"
on_chroot << EOF
cd /service/configServer && rm -f supervise && ln -s /tmp/configServer-supervise supervise
cd /etc/service && rm -f configServer && ln -s /service/configServer .
EOF

# camera
install -v -d "${ROOTFS_DIR}/service/camera"
install -m 755 files/camera_run "${ROOTFS_DIR}/service/camera/run"
install -v -d "${ROOTFS_DIR}/service/camera/log"
install -m 755 files/camera_log_run "${ROOTFS_DIR}/service/camera/log/run"

on_chroot << EOF
cd /service/camera && rm -f supervise && ln -s /tmp/camera-supervise supervise
cd /service/camera/log && rm -f supervise && ln -s /tmp/camera-log-supervise supervise
cd /etc/service && rm -f camera && ln -s /service/camera .
EOF

#
# Set up pi user scripts
#
install -m 755 -o 1000 -g 1000 files/runCamera "${ROOTFS_DIR}/home/pi/"
install -m 755 -o 1000 -g 1000 files/runInteractive "${ROOTFS_DIR}/home/pi/"
install -m 755 -o 1000 -g 1000 files/runService "${ROOTFS_DIR}/home/pi/"

