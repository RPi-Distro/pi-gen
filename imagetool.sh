#!/bin/bash

if [ "$(id -u)" != "0" ]; then
		echo "Please run as root" 1>&2
		exit 1
fi

progname=$(basename $0)

function usage()
{
	cat << HEREDOC

Usage:
    Mount Image : $progname [--mount] [--image-name <path to qcow2 image>] [--mount-point <mount point>]
    Umount Image: $progname [--umount] [--mount-point <mount point>]
    Cleanup NBD : $progname [--cleanup]

   arguments:
     -h, --help           show this help message and exit
     -c, --cleanup        cleanup orphaned device mappings
     -m, --mount          mount image
     -u, --umount         umount image
     -i, --image-name     path to qcow2 image
     -p, --mount-point    mount point for image

   This tool will use /dev/nbd1 as default for mounting an image. If you want to use another device, execute like this:
   NBD_DEV=/dev/nbd2 ./$progname --mount --image-name <your image> --mount-point <your path>

HEREDOC
}

MOUNT=0
UMOUNT=0
IMAGE=""
MOUNTPOINT=""

nbd_cleanup() {
	DEVS="$(lsblk | grep nbd | grep disk | cut -d" " -f1)"
	if [ ! -z "${DEVS}" ]; then
		for d in $DEVS; do
			if [ ! -z "${d}" ]; then
				QDEV="$(ps xa | grep $d | grep -v grep)"
				if [ -z "${QDEV}" ]; then
					kpartx -d /dev/$d && echo "Unconnected device map removed: /dev/$d"
				fi
			fi
		done
	fi
}

# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		-h|--help)
			usage
		exit
		;;
		-c|--cleanup)
			nbd_cleanup
		;;
		-m|--mount)
			MOUNT=1
		;;
		-u|--umount)
			UMOUNT=1
		;;
		-i|--image-name)
			shift
			IMAGE="$1"
		;;
		-p|--mount-point)
			shift
			MOUNTPOINT="$1"
		;;
		*)
			echo "Unknown option '$key'"
			usage
			exit
		;;
	esac
	# Shift after checking all the cases to get the next option
	shift
done

if [ "${MOUNT}" = "1" ] && [ "${UMOUNT}" = "1" ]; then
	usage
	echo "Concurrent mount options not possible."
	exit
fi

if [ "${MOUNT}" = "1" ] && ([ -z "${IMAGE}"  ] || [ -z "${MOUNTPOINT}"  ]); then
	usage
	echo "Can not mount image. Image path and/or mount point missing."
	exit
fi

if [ "${UMOUNT}" = "1" ] && [ -z "${MOUNTPOINT}" ]; then
	usage
	echo "Can not umount. Mount point parameter missing."
	exit
fi

export NBD_DEV="${NBD_DEV:-/dev/nbd1}"
export MAP_BOOT_DEV=/dev/mapper/nbd1p1
export MAP_ROOT_DEV=/dev/mapper/nbd1p2
source scripts/qcow2_handling

if [ "${MOUNT}" = "1" ]; then
	mount_qimage "${IMAGE}" "${MOUNTPOINT}"
elif [ "${UMOUNT}" = "1" ]; then
	umount_qimage "${MOUNTPOINT}"
fi
