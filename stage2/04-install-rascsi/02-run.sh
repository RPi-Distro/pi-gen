#!/bin/bash -e

on_chroot << EOF
su pi
cd /home/pi/images
wget https://www.dropbox.com/s/2ntw4h1mrdg1mhv/RaSCSI-Boot-6.0.8.hda_.zip
wget https://www.dropbox.com/s/7s6skt71xblmt2a/RaSCSI-Boot-7.0.1.hda_.zip
wget https://www.dropbox.com/s/u2w4hjdvdife2ts/RaSCSI-Boot-7.5.3.hda_.zip
wget https://www.dropbox.com/s/q3h8fi54f8ry2rq/RaSCSI-Boot-8.hda_.zip
wget https://www.dropbox.com/s/wihtro6fwfze2nm/RaSCSI-BootstrapV3.hda_.zip
EOF
