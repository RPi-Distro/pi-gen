#!/usr/bin/env bash


on_chroot << EOF
if ! ansible --version >/dev/null; then
    git clone git://github.com/ansible/ansible.git
    cd ansible
    git checkout stable-2.6
    source ./hacking/env-setup
    make && make install
    ansible --version
    mkdir -p /etc/ansible
    echo -e "[local]\nlocalhost ansible_connection=local" | tee /etc/ansible/hosts > /dev/null
fi
EOF
