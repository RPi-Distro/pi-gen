
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF
