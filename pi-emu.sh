#!/bin/bash

exists() { type -P $1 >/dev/null 2>&1; }
die() { echo "$*"; exit 1; }

exists qemu-img || die "you need qemu-img installed..."
exists mcopy || die "you need mtools installed..."
exists qemu-system-aarch64 || die "you need qemu-system-aarch64 installed..."
exists fdisk || die "you need fdisk installed..."
exists awk || die "you need awk installed..."


if [ "$EUID" -ne 0 ]; then
	die "ERROR: This script must be run as root."
fi

if [ -f emu-data/openwebrx.qcow2 ]; then
	echo "INFO: openwebrx.qcow2 already exists in emu-data/, delete it first if you want to recreate it."
else
	echo "INFO: Creating openwebrx.qcow2 in emu-data/ from OpenWebRX zip."
	mkdir -p emu-data
	zip=$1

	if [ -z "$zip" ]; then
		die "Usage: $0 <path-to-OpenWebRX-zip>"
	fi

	rm -f emu-data/*OpenWebRX*.img
	unzip -o "$zip" -d emu-data/

	shopt -s nullglob
	files=(emu-data/*OpenWebRX*.img)
	shopt -u nullglob
	IMAGE_FILE="${files[0]}" || true
	[ -n "$IMAGE_FILE" ] || die "No OpenWebRX image found in emu-data/"
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

	echo "Creating default user pi:raspberry and enabling ssh"
	touch ssh
	echo 'pi:$6$rBoByrWRKMY1EHFy$ho.LISnfm83CLBWBE/yqJ6Lq1TinRlxw/ImMTPcvvMuUfhQYcMmFnpFXUPowjy2br1NA0IACwF9JKugSNuHoe0' > userconf
	mcopy -o ssh x:/
	mcopy -o userconf x:/
	rm -f ssh userconf

	qemu-img convert -f raw emu-data/*OpenWebRX*.img -O qcow2 emu-data/openwebrx.qcow2
	rm -f emu-data/*OpenWebRX*.img
fi

echo;echo;echo "Starting pi-emu with OpenWebRX image... Use Ctrl+a c to get QEMU console, then system_powerdown to shutdown cleanly."
echo "OWRX: http://localhost:8073"
echo "SSH: ssh pi@localhost -p2222 # password: raspberry"

docker run --rm -it -p 2222:2222 -e IMAGE_FILE_NAME=openwebrx.qcow2 -v $PWD/emu-data:/dist ptrsr/pi-ci start

