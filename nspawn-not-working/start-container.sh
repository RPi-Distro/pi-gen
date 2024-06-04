#!/bin/bash

mkdir -p ./debian-containers/bookworm
sudo systemd-nspawn \
  -M debian \
  --hostname=debian \
  --bind=$(pwd)/pi-gen/:/root/pi-gen:rootidmap \
  --bind=/dev/loop-control \
  --property="DeviceAllow=/dev/loop-control rwm" \
  --property="DeviceAllow=block-loop rwm" \
  --property="DeviceAllow=block-blkext rwm" \
  --capability=CAP_MKNOD \
  -b -D ./debian-containers/bookworm


#  --capability=CAP_MKNOD \
#  --capability=all \
#  --system-call-filter=@known \
#  --bind=/usr/bin/qemu-aarch64-static \

