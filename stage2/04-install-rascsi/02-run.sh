#!/bin/bash -e

on_chroot << EOF
su pi
cd /home/pi/images
wget https://github.com/akuker/rascsi-bootstrap-images/raw/main/RaSCSI-BootstrapV2.hda_.zip
wget https://github.com/akuker/rascsi-bootstrap-images/raw/main/RaSCSI-Boot-6.0.8.hda_.zip
wget https://github.com/akuker/rascsi-bootstrap-images/raw/main/RaSCSI-Boot-7.0.1.hda_.zip
wget https://github.com/akuker/rascsi-bootstrap-images/raw/main/RaSCSI-Boot-7.5.3.hda_.zip
wget https://github.com/akuker/rascsi-bootstrap-images/raw/main/DaynaPORT7.5.3.sit_.hqx
EOF
