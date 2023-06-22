# Create the unix user
on_chroot << EOF
adduser sth --system --home /usr/lib/sth
addgroup sth --system

# Add them to groups
usermod -aG sudo sth
usermod -aG gpio sth

# Create a sth-owned folder to put the app in
# You call this whatever you like, probably the name of your application
mkdir -p /usr/lib/sth
EOF

install -d                          "${ROOTFS_DIR}/usr/lib/sth/bin"
install -m 755 files/start-sth.sh   "${ROOTFS_DIR}/usr/lib/sth/bin/"
install -m 644 files/sth.service    "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
chown -R sth:sth /usr/lib/sth
systemctl enable sth
EOF
