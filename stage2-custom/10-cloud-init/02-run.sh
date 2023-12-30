#!/bin/bash -e

install -m 644 -t "${ROOTFS_DIR}/boot/firmware/" files/boot/*
