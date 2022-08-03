# Create the unix user
adduser sth --system --home /usr/lib/sth

# Add them to groups
usermod -aG sudo sth
usermod -aG gpio sth

# Create a sth-owned folder to put the app in
# You call this whatever you like, probably the name of your application
mkdir -p /usr/lib/sth
chown -R sth:sth /usr/lib/sth

install -d                          "${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/sth.service    "${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

on_chroot << EOF
systemctl enable sth
EOF
