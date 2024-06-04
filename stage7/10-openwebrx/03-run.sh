#!/usr/bin/env bash
set -euo pipefail

# move openwebrx temporary file off into tmpfs (ramdisk)
mkdir -p "${ROOTFS_DIR}/tmp/openwebrx"
echo "tmpfs /tmp/openwebrx tmpfs defaults,noatime,nosuid,size=64m 0 0" >> "${ROOTFS_DIR}/etc/fstab"

mkdir -p "${ROOTFS_DIR}/etc/openwebrx/openwebrx.conf.d"
cat << EOF > "${ROOTFS_DIR}/etc/openwebrx/openwebrx.conf.d/20-temporary-directory.conf"
[core]
temporary_directory = /tmp/openwebrx
EOF

cp files/profile-owrx.sh "${ROOTFS_DIR}/etc/profile.d/owrx.sh"
cp files/install-softmbe.sh "${ROOTFS_DIR}/usr/local/bin"
chmod +x "${ROOTFS_DIR}/usr/local/bin/install-softmbe.sh"

cat > "${ROOTFS_DIR}/etc/modprobe.d/openwebrx.conf" << _EOF_
blacklist dvb_usb_rtl28xxu
blacklist sdr_msi3101
blacklist msi001
blacklist msi2500
blacklist hackrf
_EOF_

