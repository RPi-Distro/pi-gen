#!/bin/bash -e

wget https://github.com/BlokasLabs/rpi-kernel-rt/archive/${RT_KERNEL_VERSION}.tar.gz -O /tmp/${RT_KERNEL_VERSION}.tar.gz

# Remove regular kernel modules.
rm -r ${ROOTFS_DIR}/lib/modules/*

tar -xvf /tmp/${RT_KERNEL_VERSION}.tar.gz --strip 1 -C ${ROOTFS_DIR}/
rm /tmp/${RT_KERNEL_VERSION}.tar.gz
