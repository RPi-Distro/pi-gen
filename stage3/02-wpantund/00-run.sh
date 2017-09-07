#!/bin/bash -e

#install -m 755 files/wpantund   ${ROOTFS_DIR}/usr/sbin/
#install -m 755 files/wpanctl    ${ROOTFS_DIR}/usr/bin/
#install -d files/etc ${ROOTFS_DIR}/
#install -d files/usr ${ROOTFS_DIR}/

install -d ${ROOTFS_DIR}/usr/local/bin/ ${ROOTFS_DIR}/usr/local/sbin/ ${ROOTFS_DIR}/usr/local/libexec/wpantund/
install -m 755 files/usr/local/bin/wpanctl                    ${ROOTFS_DIR}/usr/local/bin/
install -m 755 files/usr/local/sbin/wpantund                  ${ROOTFS_DIR}/usr/local/sbin/
install -m 755 files/usr/local/libexec/wpantund/ncp-spinel.la ${ROOTFS_DIR}/usr/local/libexec/wpantund/
install -m 755 files/usr/local/libexec/wpantund/ncp-dummy.so  ${ROOTFS_DIR}/usr/local/libexec/wpantund/
install -m 755 files/usr/local/libexec/wpantund/ncp-dummy.la  ${ROOTFS_DIR}/usr/local/libexec/wpantund/
install -m 755 files/usr/local/libexec/wpantund/ncp-spinel.so ${ROOTFS_DIR}/usr/local/libexec/wpantund/
install -m 644 files/etc/dbus-1/system.d/wpantund.conf        ${ROOTFS_DIR}/etc/dbus-1/system.d/
install -m 644 files/etc/wpantund.conf                        ${ROOTFS_DIR}/etc/
install -m 644 files/etc/systemd/system/wpantund.service      ${ROOTFS_DIR}/etc/systemd/system/

on_chroot << EOF
  systemctl disable wpantund
EOF
