# Set up automatic start of PulseAudio Jack bridge when X gets started.
cp files/pulseaudio-jack.desktop ${ROOTFS_DIR}/etc/xdg/autostart/

# configure pulseaudio to get realtime capability
cp files/daemon.conf ${ROOTFS_DIR}/etc/pulse/

