#!/bin/bash

sudo raspi-config nonint do_boot_behaviour B3
dpkg-reconfigure lightdm
mkdir ~/Activities
cd ~/Activities
git clone https://github.com/44yu5h/gallery_activity.git
echo "###### Finished 01-run.sh #####"
