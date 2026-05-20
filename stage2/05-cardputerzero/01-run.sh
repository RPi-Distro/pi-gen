#!/bin/bash -e

# Compile and install CardputerZero kernel modules + overlay
on_chroot << 'CHROOT'
set -e

# Install build dependencies
apt-get install -y --no-install-recommends \
    build-essential \
    linux-headers-rpi-v8 \
    device-tree-compiler \
    git

# Clone driver source
git clone --depth=1 https://github.com/m5stack/m5stack-linux-dtoverlays.git /tmp/dtoverlays

KVER=$(ls /lib/modules/ | grep rpi-v8 | head -1)
export KERNELDIR="/lib/modules/${KVER}/build"

# make and install st7789v overlay + module
cd /tmp/dtoverlays/modules/CardputerZero
make KERNELDIR="$KERNELDIR" install
make KERNELDIR="$KERNELDIR" config_setup

# Update module dependencies
depmod -a "${KVER}"

# Clean up build artifacts only (keep all build tools for user driver builds)
rm -rf /tmp/dtoverlays

CHROOT
