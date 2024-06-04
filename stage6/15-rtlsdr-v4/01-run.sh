#!/usr/bin/env bash
set -euo pipefail
echo "blacklist dvb_usb_rtl28xxu" > "${ROOTFS_DIR}/etc/modprobe.d/rtlsdr_blacklist.conf"
