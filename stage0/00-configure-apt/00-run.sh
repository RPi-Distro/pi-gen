#!/bin/bash -e

# if either CUSTOM_LIST or CUSTOM_LIST_DIR is set, then install sources from there
set -x

echo "$CUSTOM_LIST"
echo "$CUSTOM_LIST_DIR"

if [ -n "$CUSTOM_LIST" -o -n "$CUSTOM_LIST_DIR" ]; then
    if [ -n "$CUSTOM_LIST" ]; then
        if [ -f "$CUSTOM_LIST" ]; then
            install -m 644 "$CUSTOM_LIST" "${ROOTFS_DIR}/etc/apt/sources.list" || exit 1
        else
            echo "$CUSTOM_LIST cannot be found"; exit 1
        fi
    fi
    if [ -n "$CUSTOM_LIST_DIR" ]; then
        if [ -d "$CUSTOM_LIST_DIR" ]; then
            install -m 644 "$CUSTOM_LIST_DIR"/* "${ROOTFS_DIR}/etc/apt/sources.list.d/" || exit 1
        else
            echo "$CUSTOM_LIST_DIR cannot be found"; exit 1
        fi
    fi

# otherwise, use the standard sources as provided by pi-gen
else
    install -m 644 files/sources.list "${ROOTFS_DIR}/etc/apt/"
    install -m 644 files/raspi.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
fi

# replace 'RELEASE' with "$RELEASE" in all .list files
if [ -f "${ROOTFS_DIR}/etc/apt/sources.list" ]; then
    sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list"
fi
find "${ROOTFS_DIR}/etc/apt/sources.list.d/" -type f -exec sed -i "s/RELEASE/${RELEASE}/g" {} \;

if [ -n "$APT_PROXY" ]; then
	install -m 644 files/51cache "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
	sed "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache" -i -e "s|APT_PROXY|${APT_PROXY}|"
else
	rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
fi

on_chroot apt-key add - < files/raspberrypi.gpg.key
on_chroot << EOF
apt-get update
apt-get dist-upgrade -y
EOF
