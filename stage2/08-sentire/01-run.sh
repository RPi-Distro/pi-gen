SENTIRE_VERSION=0.3.0

# Install JITLibExtensions
install -m 644 files/install_jitlibext.scd "${ROOTFS_DIR}/tmp/"

on_chroot <<EOF
    su sentire -c 'sclang /tmp/install_jitlibext.scd'
EOF

# Install ws2udp
on_chroot <<EOF
    pip3 install ws2udp
EOF

# Install sentire
install -m 644 files/sentire-0.3.0.zip "${ROOTFS_DIR}/tmp/"

on_chroot <<EOF
    unzip "/tmp/sentire-${SENTIRE_VERSION}.zip" -d "/home/sentire/"
    mv /home/sentire/sentire-*${SENTIRE_VERSION}* /home/sentire/sentire
    cp /home/sentire/sentire/RPi4/sclang_conf_rpi4.yaml /home/sentire/.config/SuperCollider/sclang_conf.yaml
    chown -R sentire:sentire /home/sentire/
EOF

# Setup sentire startup files
install -m 755 files/sentire		            "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/sentire.service		    "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot <<EOF
    systemctl enable sentire.service
EOF

# Cleanup
rm "${ROOTFS_DIR}/tmp/sentire-${SENTIRE_VERSION}.zip"
rm "${ROOTFS_DIR}/tmp/install_jitlibext.scd"

