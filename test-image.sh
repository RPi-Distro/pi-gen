#!/bin/bash

exists() { type -P $1 >/dev/null 2>&1; }
die() { echo "$*"; exit 1; }

exists qemu-img || die "you need qemu-img installed..."
exists mcopy || die "you need mtools installed..."
exists qemu-system-aarch64 || die "you need qemu-system-aarch64 installed..."
exists fdisk || die "you need fdisk installed..."
exists awk || die "you need awk installed..."

if [ -z $1 ] || [ ! -f $1 ]; then
  echo "usage: $0 ./deploy/[image]"
  exit 1
fi

EMU_RPI3=1 # working
EMU_RPI4=0 # no net and kbd yet
EMU_VIRT=0 # not working yet... root device?

if [ ${EMU_RPI3} == 1 ]; then
	echo "Emulating Raspberry 3B..."
	EMU_MACHINE=raspi3b
	EMU_DTB=bcm2710-rpi-3-b-plus.dtb
	EMU_KERNEL=kernel8.img
	EMU_MEM=1G
	EMU_ROOT=/dev/mmcblk0p2
fi

if [ ${EMU_RPI4} == 1 ]; then
	echo "Emulating Raspberry 4B..."
	EMU_MACHINE=raspi4b
	EMU_DTB=bcm2711-rpi-4-b.dtb
	EMU_KERNEL=kernel8.img
	EMU_MEM=2G
	EMU_ROOT=/dev/mmcblk1p2
fi

if [ ${EMU_VIRT} == 1 ]; then
	echo "Emulating Raspberry Generic ARM..."
	EMU_MACHINE=virt
	EMU_KERNEL=kernel8.img
	EMU_MEM=4G
	EMU_ROOT=/dev/vda2
fi


IMAGE_FILE=$1
sudo chown $(id -u):$(id -g) ${IMAGE_FILE}
CURRENT_SIZE=$(stat -c%s "${IMAGE_FILE}")
NEXT_POWER_OF_TWO=$(python3 -c "import math; print(2**(math.ceil(math.log(${CURRENT_SIZE}, 2))))")
OFFSET=$(fdisk -lu ${IMAGE_FILE} | awk '/^Sector size/ {sector_size=$4} /FAT32 \(LBA\)/ {print $2 * sector_size}')

echo "Image: $IMAGE_FILE, size: $(($CURRENT_SIZE/1024/1024)) MB, will resize to: $(($NEXT_POWER_OF_TWO/1024/1024)) MB"
echo
echo "You need to run 'raspi-config' and use Advanced menu to resize the FS internaly..."
echo
echo "Resizing image..."
qemu-img resize -f raw "${IMAGE_FILE}" "${NEXT_POWER_OF_TWO}"

echo "Preparing mtools..."
echo "drive x: file=\"${IMAGE_FILE}\" offset=${OFFSET}" > ~/.mtoolsrc




echo "Getting artefacts..."
mkdir -p ./artefacts/
mcopy -n x:/${EMU_DTB} ./artefacts/
mcopy -n x:/${EMU_KERNEL} ./artefacts/

echo "Creating default user pi:raspberry and enabling ssh"
touch ssh
echo 'pi:$6$rBoByrWRKMY1EHFy$ho.LISnfm83CLBWBE/yqJ6Lq1TinRlxw/ImMTPcvvMuUfhQYcMmFnpFXUPowjy2br1NA0IACwF9JKugSNuHoe0' > userconf
mcopy -o ssh x:/
mcopy -o userconf x:/
rm -f ssh userconf

echo "This will take a while before you can ssh into the emulated RPi..."
echo "OWRX: http://localhost:8073"
echo "SSH: ssh pi@localhost -p2222 # password: raspberry"
echo

if [ ${EMU_RPI3} == 1 ] || [ ${EMU_RPI4} == 1 ]; then
	EMU_EXTRA1=""
	EMU_EXTRA2="-dtb artefacts/${EMU_DTB} -usb -device usb-mouse -device usb-kbd -device usb-net,netdev=rpi-net0 -serial stdio"
	EMU_SDDEV=sd-card
else
	EMU_EXTRA1=""
	EMU_EXTRA2="-device virtio-net,netdev=rpi-net0 -cpu cortex-a72 -nographic"
	EMU_SDDEV=virtio-blk-pci
fi

qemu-system-aarch64 \
  -accel tcg \
  -machine ${EMU_MACHINE} \
  -m ${EMU_MEM} \
  -smp 4 \
  ${EMU_EXTRA1} \
  -kernel artefacts/${EMU_KERNEL} \
  -drive id=mydrive,if=none,format=raw,file=${IMAGE_FILE},cache=writeback \
  -device ${EMU_SDDEV},drive=mydrive \
  -append "rw earlyprintk loglevel=8 console=serial0,115200 console=ttyS0 console=tty highres=off console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=${EMU_ROOT} rootdelay=1 rootwait" \
  -no-reboot \
  -netdev user,id=rpi-net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8073-:8073 \
  ${EMU_EXTRA2}

#  -device ${EMU_SDDEV},drive=mydrive \

#  -usb \
#  -device usb-mouse -device usb-kbd \
#  -net nic \


#  -netdev tap,id=rpi-tap0,ifname=rpi0,script=no,downscript=no \
#  -device usb-net,netdev=rpi-tap0
#  -netdev bridge,id=rpi-br0 \
#  -device usb-net,netdev=rpi-br0 \
  #-nographic \


#qemu-system-aarch64 \
#  -machine raspi3b \
#  -dtb artefacts/bcm2710-rpi-3-b-plus.dtb \
#  -nographic \
#  -m 1G \
#  -smp 4 \
#  -kernel artefacts/kernel8.img \
#  -device sd-card,drive=mydrive \
#  -drive id=mydrive,if=none,format=raw,file=${IMAGE_FILE},cache=writeback \
#  -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
#  -device usb-net,netdev=net0 \
#  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8073-:8073
