on_chroot << EOF
	SUDO_USER=pi raspi-config nonint do_boot_behaviour B4
	raspi-config nonint do_xcompmgr 0
	SUDO_USER=pi raspi-config nonint do_wayland W2
EOF

on_chroot << EOF
    systemctl --user -M pi@ mask pipewire
    systemctl --user -M pi@ mask pipewire-pulse
    apt-get purge -y cups cups-common
    apt-get autoremove
EOF
install -m 644 files/lightdm.ini ${ROOTFS_DIR}/etc/lightdm/lightdm.conf

