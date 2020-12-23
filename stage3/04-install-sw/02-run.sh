# Setup VNC server.

# install noVNC
git clone --depth 1 --branch v1.2.0 https://github.com/novnc/noVNC.git ${ROOTFS_DIR}/usr/local/noVNC/
git clone --depth 1 --branch v0.9.0 https://github.com/novnc/websockify.git ${ROOTFS_DIR}/usr/local/noVNC/utils/websockify
cp ${ROOTFS_DIR}/usr/local/noVNC/vnc.html ${ROOTFS_DIR}/usr/local/noVNC/index.html

# install novnc service file
install -m 644 files/novnc.service ${ROOTFS_DIR}/lib/systemd/system

# VNC password is stored in encrypted form.
# generate encrypted password with:
#   echo <vnc_password> | vncpasswd -print
# Default VNC password is "jambox"
# VNC password may be set in config file as follows:
#   export VNC_PASS_CRYPT="70dc86dbbe2f1bc7"
#
[[ -z "$VNC_PASS_CRYPT" ]] && VNC_PASS_CRYPT="70dc86dbbe2f1bc7"

mkdir -p ${ROOTFS_DIR}/root/.vnc/config.d
cat << EOF >> ${ROOTFS_DIR}/root/.vnc/config.d/vncserver-x11
Authentication=VncAuth
Encryption=PreferOff
Password=${VNC_PASS_CRYPT}
EOF

on_chroot << EOF
	systemctl enable vncserver-x11-serviced.service
	systemctl enable novnc.service
EOF
