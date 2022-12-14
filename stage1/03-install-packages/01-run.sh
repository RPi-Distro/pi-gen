on_chroot << EOF
usermod -aG sudo {FIRST_USER_NAME}
usermod --pass='*' root
EOF