#!/bin/bash -e
if [ ! -d ${ROOTFS_DIR} ]; then
	bootstrap jessie ${ROOTFS_DIR} http://mirrordirector.raspbian.org/raspbian/
fi
