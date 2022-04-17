#!/bin/bash -e

install -m 644 files/sources.list "${ROOTFS_DIR}/etc/apt/"
install -m 644 files/raspi.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/raspi.list"

if [ -n "$APT_PROXY" ]; then
	if [ "$APT_PROXY_FALLBACK" == "1" ]; then
		install -m 644 files/52fallback "${ROOTFS_DIR}/etc/apt/apt.conf.d/52fallback"
		install -m 755 files/detect-proxy "${ROOTFS_DIR}/bin/detect-proxy"
		sed "${ROOTFS_DIR}/bin/detect-proxy" -i -e "s|APT_PROXY|${APT_PROXY}|"
	else
		install -m 644 files/51cache "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
		sed "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache" -i -e "s|APT_PROXY|${APT_PROXY}|"
		
		rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/52fallback"
		rm -f "${ROOTFS_DIR}/bin/detect-proxy"
	fi
else
	rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
	rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/52fallback"
	rm -f "${ROOTFS_DIR}/bin/detect-proxy"
fi

cat files/raspberrypi.gpg.key | gpg --dearmor > "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/raspberrypi-archive-stable.gpg"
on_chroot << EOF
apt-get update
apt-get dist-upgrade -y
EOF
