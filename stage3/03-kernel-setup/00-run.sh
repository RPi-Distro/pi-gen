on_chroot << EOF
    sed -i 's/$/ threadirqs/' /boot/cmdline.txt
EOF
