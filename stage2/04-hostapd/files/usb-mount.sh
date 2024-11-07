#!/bin/bash

DEVICE="/dev/$1"

MOUNT_OPTS=""
FS_UID_GID="vfat exfat ntfs fuseblk"

# Get filesystem type
FSTYPE=$(blkid -o value -s TYPE "$DEVICE")
if [ -z "$FSTYPE" ]; then
    logger "usb-mount: No filesystem type found for $DEVICE"
    exit 1
fi

# Get label or use device name
LABEL=$(blkid -o value -s LABEL "$DEVICE")
if [ -z "$LABEL" ]; then
    LABEL=$(basename "$DEVICE")
fi

MOUNT_POINT="/media/usb/$LABEL"
if echo "$FS_UID_GID" | grep -qw "$FSTYPE"; then
   MOUNT_OPTS="-o uid=1000,gid=1000"
fi

mkdir -p "$MOUNT_POINT"
mount $MOUNT_OPTS "$DEVICE" "$MOUNT_POINT"
if [ $? -eq 0 ]; then
    #chown -R 1000:1000 "$MOUNT_POINT"
    logger "usb-mount: Mounted $DEVICE at $MOUNT_POINT"
else
    logger "usb-mount: Failed to mount $DEVICE"
    rmdir "$MOUNT_POINT"
fi
