#!/bin/bash -e

# Add checkout to production branch later

on_chroot << EOF
  git clone https://github.com/Screenly/screenly-ose.git /home/pi/screenly
  cd /home/pi/screenly
  pip install -r requirements.txt
  cd ansible
  HOME=/home/pi ansible-playbook site.yml --skip-tags enable-ssl,disable-nginx,touches_boot_partition
  chown -R pi:pi /home/pi/screenly
  pip uninstall -y pyopenssl
  apt-get autoclean
  apt-get clean
EOF
