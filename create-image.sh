#!/bin/bash

for i in "$@"
do
case $i in
    # Name for image
    -i=*|--imagename=*)      
    IMAGE_NAME="${i#*=}"
    shift
    ;;
    
    # Which stage to create image from
    -s=*|--stage=*)      
    STAGE_NUM="${i#*=}"
    shift
    ;;
    
    # unknown option
    *)        
    ;;
esac
done

if [ ${EUID} -ne 0 ]; then
  echo "this tool must be run as root"
  exit 1
fi

if [ -z "$IMAGE_NAME" ]
then
  echo "No image name specified, defaulting to \"raspbian\""
  IMAGE_NAME="raspbian"
fi

if [ -z "$STAGE_NUM" ]
then
  echo "No stage specified, aborting."
  exit 2
fi

WORKSPACE_PATH="./work/${IMAGE_NAME}/stage${STAGE_NUM}"

work_path=$(readlink -f $WORKSPACE_PATH)

if [ ! -d "$work_path" ]
then
  echo "Error resolving workspace path. Does not exist: work_path=\"${work_path}\""
  exit 3
fi

echo "Creating image using rootfs in: ${work_path}"

bootsize="64M"
deb_release="jessie"

# define destination folder where created image file will be stored
buildenv="${PWD}/images"

# Set directory of rootfs and bootfs
rootfs="${buildenv}/rootfs"
bootfs="${buildenv}/boot"

today=`date +%Y%m%d`

mkdir -p ${buildenv}
mkdir -p ${buildenv}/images

# Construct image name
image="${buildenv}/images/${IMAGE_NAME}.img"

# Create a blank image file
dd if=/dev/zero of=${image} bs=1MB count=3800

# Mount it on the loop back adapter
device=`losetup -f --show ${image}`

echo "image ${image} created and mounted as ${device}"

# Set up partition descriptor
fdisk ${device} << EOF
n
p
1

+${bootsize}
t
c
n
p
2


w
EOF


if [ "${image}" != "" ]; then
  # Delete the loopback device
  losetup -d ${device}
  
  # Mount the disk image
  device=`kpartx -va ${image} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
  echo device
  device="/dev/mapper/${device}"
  echo device
  
  # Get paths to boot and root partitions
  bootp=${device}p1
  rootp=${device}p2
fi

# Create the filesystems
mkfs.vfat ${bootp}
mkfs.ext4 ${rootp}

# Set the path to the rootfs
mkdir -p ${rootfs}

# Mount the rootfs to the root partition
mount ${rootp} ${rootfs}

# copy
rootfs_work="${work_path}/rootfs"
rsync -a ${rootfs_work}/ ${rootfs}

# Remove the contents of the boot folder, but not the boot folder itself
rm -rf ${rootfs}/boot/*

#unmount
umount ${rootp}

sync

bootfs_work="${rootfs_work}/boot"
mkdir -p ${bootfs}

mount ${bootp} ${bootfs}

cp -R ${bootfs_work}/* ${bootfs}

umount ${bootfs}

sync

rm -rf ${rootfs}
rm -rf ${bootfs}

# Remove device mapper bindings. Avoids running out of loop devices if run repeatedly.
dmsetup remove_all

echo "finishing ${image}"

if [ "${image}" != "" ]; then
  kpartx -d ${image}
  echo "created image ${image}"
fi

echo "done."
