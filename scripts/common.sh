# bash #

log (){
	date +"[%T] $@" | tee -a ${LOG_FILE}
}
export -f log

bootstrap(){
	local ARCH=$(dpkg --print-architecture)

	export http_proxy=${APT_PROXY}

	if [ "$ARCH" !=  "armhf" ]; then
		local BOOTSTRAP_CMD=qemu-debootstrap
	else
		local BOOTSTRAP_CMD=debootstrap
	fi

	${BOOTSTRAP_CMD} --components=main,contrib,non-free \
		--arch armhf\
		--no-check-gpg \
		$1 $2 $3
}
export -f bootstrap

copy_previous(){
	if [ ! -d ${PREV_ROOTFS_DIR} ]; then
		echo "Previous stage rootfs not found"
		false
	fi
	mkdir -p ${ROOTFS_DIR}
	rsync -aHAX ${PREV_ROOTFS_DIR}/ ${ROOTFS_DIR}/
}
export -f copy_previous

unmount(){
	if [ -z "$1" ]; then
		DIR=$PWD
	else
		DIR=$1
	fi

	while mount | grep -q $DIR; do
		local LOCS=`mount | grep $DIR | cut -f 3 -d ' ' | sort -r`
		for loc in $LOCS; do
			umount $loc
		done
	done
}
export -f unmount

unmount_image(){
	sync
	sleep 1
	local LOOP_DEV=$(losetup -j ${1} | cut -f1 -d':')
	if [ -n "${LOOP_DEV}" ]; then
		local MOUNTED_DIR=$(mount | grep $(basename ${LOOP_DEV}) | head -n 1 | cut -f 3 -d ' ')
		if [ -n "${MOUNTED_DIR}" ]; then
			unmount $(dirname ${MOUNTED_DIR})
		fi
		sleep 1
		kpartx -ds ${LOOP_DEV}
		losetup -d ${LOOP_DEV}
	fi
}
export -f unmount_image

on_chroot() {
	if ! mount | grep -q `realpath ${ROOTFS_DIR}/proc`; then
		mount -t proc proc ${ROOTFS_DIR}/proc
	fi

	if ! mount | grep -q `realpath ${ROOTFS_DIR}/dev`; then
		mount --bind /dev ${ROOTFS_DIR}/dev
	fi
	
	if ! mount | grep -q `realpath ${ROOTFS_DIR}/dev/pts`; then
		mount --bind /dev/pts ${ROOTFS_DIR}/dev/pts
	fi

	if ! mount | grep -q `realpath ${ROOTFS_DIR}/sys`; then
		mount --bind /sys ${ROOTFS_DIR}/sys
	fi

	chroot ${ROOTFS_DIR}/ "$@"
}
export -f on_chroot

update_issue() {
	local GIT_HASH=$(git rev-parse HEAD)
	echo -e "Raspberry Pi reference ${IMG_DATE}\nGenerated using pi-gen, https://github.com/RPi-Distro/pi-gen, ${GIT_HASH}, ${1}" > ${ROOTFS_DIR}/etc/rpi-issue
}
export -f update_issue
