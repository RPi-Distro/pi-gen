#!/usr/bin/env bash

rm "${ROOTFS_DIR}/etc/nginx/sites-enabled/default"

install -m 644 files/openwebrx.site "${ROOTFS_DIR}/etc/nginx/sites-available/openwebrx"
ln -sf "/etc/nginx/sites-available/openwebrx" "${ROOTFS_DIR}/etc/nginx/sites-enabled/openwebrx"
