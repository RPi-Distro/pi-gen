install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"
install -m 755 files/cpufrequtils   "${ROOTFS_DIR}/etc/default/"
install -m 755 files/limits.conf    "${ROOTFS_DIR}/etc/security/"
install -m 755 files/sysctl.conf    "${ROOTFS_DIR}/etc/"
