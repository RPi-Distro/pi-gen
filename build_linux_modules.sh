#!/bin/bash
mkdir -p work_linux
cd work_linux
#git clone --depth=1 --branch 1.20220331 https://github.com/corneliusclaussen/linux.git
git clone --depth=1 --branch 1.20220331 https://github.com/raspberrypi/linux
cd linux
echo "CONFIG_DM_VERITY=m" >> arch/arm/configs/bcm2711_defconfig
echo "CONFIG_DM_VERITY_VERIFY_ROOTHASH_SIG=y" >> arch/arm/configs/bcm2711_defconfig
#echo "CONFIG_DM_VERITY_FEC=n" >> arch/arm/configs/bcm2711_defconfig
export KERNEL=kernel7l
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2711_defconfig
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- prepare -j4
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_prepare -j4
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs -j4
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- SUBDIRS=scripts/mod -j4
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- SUBDIRS=drivers/dm -j4
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- deb-pkg -j4
