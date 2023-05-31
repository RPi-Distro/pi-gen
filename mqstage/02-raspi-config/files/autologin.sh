#!/bin/bash

systemctl --quiet set-default multi-user.target
        cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
        [Service]
        ExecStart=
        ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF