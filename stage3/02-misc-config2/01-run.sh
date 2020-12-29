install -m 644 files/cpu_performance_scaling_governor.service ${ROOTFS_DIR}/lib/systemd/system
# install -m 644 files/rules.v4 ${ROOTFS_DIR}/etc/iptables

on_chroot << EOF
	systemctl disable wifi-hotspot
	systemctl enable cpu_performance_scaling_governor
	systemctl disable raspi-config # raspi-config is only enabling 'ondemand' governor as of 2018.08.19
EOF
