#!/bin/bash -e

BASE_DIR=$(pwd)


########################
# Install dependencies #
########################
#dpkg --add-architecture i386

apt-get update
apt-get install -y make python build-essential
apt-get install -y curl
apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
#apt-get install -y gcc-multilib g++-multilib
#apt-get install -y libc6-dev-i386

#apt-get install -y libc6-dev

apt-get --purge remove node
apt-get --purge remove nodejs
curl -sL https://deb.nodesource.com/setup_6.x | /bin/bash -e -
apt-get install -y nodejs
npm install -g npm@5.3.0
#npm cache clean --force

#ln -s /usr/include/asm-generic /usr/include/asm


#################
# Checkout node #
#################
NODE_BUILD_PATH=${BASE_DIR}/build/node
if [ ! -d "$NODE_BUILD_PATH" ]; then
  git clone https://github.com/nodejs/node.git $NODE_BUILD_PATH
fi
cd $NODE_BUILD_PATH
git checkout v6.11.2


#######################
# Cross-build Node.js #
#######################
 
#export BASEDIR=$(pwd)
#export STAGING_DIR=${BASEDIR}/staging_dir
#export V8SOURCE=${BASEDIR}/v8m-rb
export PREFIX=arm-linux-gnueabihf-
export LIBPATH=${ROOTFS_DIR}/usr/lib/arm-linux-gnueabihf/
export TARGET_PATH=${ROOTFS_DIR}

# ARM cross-compile exports
export CC=${PREFIX}gcc
export CXX=${PREFIX}g++
export AR=${PREFIX}ar
export RANLIB=${PREFIX}ranlib
export LINK=${PREFIX}g++
export CPP="${PREFIX}gcc -E"
export STRIP=${PREFIX}strip
export OBJCOPY=${PREFIX}objcopy
export LD=${PREFIX}g++
export OBJDUMP=${PREFIX}objdump
export NM=${PREFIX}nm
export AS=${PREFIX}as
export PS1="[${PREFIX}] \w$ "
#export LDFLAGS='-Wl,-L'${LIBPATH}
export LDFLAGS='-Wl,-rpath-link '${LIBPATH}
 
export TARGET_ARCH="-march=armv7l"
#export TARGET_TUNE="-mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -mthumb-interwork -mno-thumb"
export CXX_TARGET_ARCH="-march-armv7l"

export V8_TARGET_ARCH="-march-armv7l"
export CXX_host="g++ -m32"
export CC_host="gcc -m32" 
export LINK_host="g++ -m32"

 
make clean
make distclean
 
#./configure --prefix=${TARGET_PATH} --dest-cpu=arm --dest-os=linux --without-snapshot --with-arm-float-abi=hard --with-arm-fpu=vfpv3
./configure --prefix=${TARGET_PATH} --dest-cpu=arm --dest-os=linux --without-snapshot --with-arm-float-abi=hard --with-arm-fpu=vfpv3 --without-intl

#./configure --without-snapshot --dest-cpu=arm --dest-os=linux --with-arm-float-abi=softfp --with-intl=full-icu --download=all
 
make snapshot=off -j4
make install


#########################
# Install node packages #
#########################
cd ${BASE_DIR}

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# WAR for node-gyp build
#mkdir -p ${ROOTFS_DIR}/lib/node_modules/node-red/node_modules/bcrypt
#chown -R $USER:$GROUP ${ROOTFS_DIR}/lib/node_modules/node-red/node_modules/bcrypt

#mkdir -p ${ROOTFS_DIR}/lib/node_modules/node-red/node_modules/bcrypt/build
#chown -R $USER:$GROUP ${ROOTFS_DIR}/lib/node_modules/node-red/node_modules/bcrypt/build

#ls -la ${ROOTFS_DIR}/lib/node_modules/node-red/node_modules/bcrypt/build
#ls -la ${ROOTFS_DIR}
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

export npm_config_arch=arm
export npm_config_nodedir=${NODE_BUILD_PATH}

npm_install () {
  npm install -g --prefix=${TARGET_PATH} --target_arch=arm --target_platform=linux "$1"
}

#npm --prefix=${TARGET_PATH} --target_arch=arm --target_platform=linux cache clean --force

npm_install npm@5.3.0
npm_install node-red
npm_install coap
npm_install node-red-dashboard

# Running `npm_install repos/node-red-contrib-juliet` fails, this is a workaround
cd repos/node-red-contrib-juliet
npm install --target_arch=arm --target_platform=linux
npm_install


#######################################
# Install WPAN service Node-RED flows #
#######################################
cd ${BASE_DIR}

NODE_DIR=${ROOTFS_DIR}/home/pi/.node-red
install -m 755 -d ${NODE_DIR}
install -m 755 -d ${NODE_DIR}/scripts/
install -m 644 -D files/flows_*.json    ${NODE_DIR}/
install -m 755 -D files/*.sh            ${NODE_DIR}/scripts/
install -m 755 -D files/usbreset        ${ROOTFS_DIR}/usr/sbin/

on_chroot << EOF
  chown -R pi:pi /home/pi/.node-red
EOF

