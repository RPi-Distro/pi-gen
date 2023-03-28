#!/bin/bash -e

on_chroot << EOF
su pi
cd /home/pi/images
wget https://macintoshgarden.org/sites/macintoshgarden.org/files/apps/RaSCSI-Boot-6.0.8.hda__1.zip
wget https://macintoshgarden.org/sites/macintoshgarden.org/files/apps/RaSCSI-Boot-7.0.1.hda__0.zip
wget https://macintoshgarden.org/sites/macintoshgarden.org/files/apps/RaSCSI-Boot-7.5.3.hda__2.zip
wget https://macintoshgarden.org/sites/macintoshgarden.org/files/apps/RaSCSI-Boot-8.hda__0.zip
wget https://macintoshgarden.org/sites/macintoshgarden.org/files/apps/RaSCSI_v3_Bootstrap.hda_.zip 
EOF
