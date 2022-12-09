#!/bin/bash -e

on_chroot << EOF
su pi
cd /home/pi/images
wget https://www.dropbox.com/s/i23h12gzd9a0ka3/PiSCSI-Boot-6.0.8.hda_.zip
wget https://www.dropbox.com/s/v65129yt7b1iulq/PiSCSI-Boot-7.0.1.hda_.zip
wget https://www.dropbox.com/s/7z8ffuitabn4ujd/PiSCSI-Boot-7.5.3.hda_.zip
wget https://www.dropbox.com/s/pgfv66pzzkwihi1/PiSCSI-Boot-8.hda_.zip
wget https://www.dropbox.com/s/v9dvze0g2ei77oo/PiSCSI-BootstrapV3.hda_.zip
EOF
