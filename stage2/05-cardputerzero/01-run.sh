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

# st7789v LCD + pwm backlight
cd /tmp/dtoverlays/modules/st7789v-1.0
make KERNELDIR="$KERNELDIR"
mkdir -p /lib/modules/${KVER}/extra
cp st7789v_m5stack.ko pwm_bl_m5stack.ko /lib/modules/${KVER}/extra/

# tca8418 keyboard
cd /tmp/dtoverlays/modules/tca8418-1.0
make KERNELDIR="$KERNELDIR"
cp tca8418_keypad_m5stack.ko /lib/modules/${KVER}/extra/

# es8389 audio codec
cd /tmp/dtoverlays/modules/es8389-1.0
make KERNELDIR="$KERNELDIR"
cp es8389_m5stack.ko /lib/modules/${KVER}/extra/

# bq27220 battery
cd /tmp/dtoverlays/modules/bq27220-1.0
make KERNELDIR="$KERNELDIR"
cp bq27xxx_battery.ko bq27xxx_battery_i2c.ko bq27xxx_battery_hdq.ko /lib/modules/${KVER}/extra/

# py32ioexp
cd /tmp/dtoverlays/modules/py32ioexp-1.0
make KERNELDIR="$KERNELDIR"
cp py32ioexp.ko /lib/modules/${KVER}/extra/

# CardputerZero overlay dtbo
cd /tmp/dtoverlays/modules/CardputerZero
make
cp *.dtbo /boot/firmware/overlays/

# Update module dependencies
depmod -a "${KVER}"

# Clean up build artifacts only (keep all build tools for user driver builds)
rm -rf /tmp/dtoverlays

CHROOT
