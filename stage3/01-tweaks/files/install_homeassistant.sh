#!/bin/sh

echo "Home Assistant install script for Hassbian"
echo "Copyright(c) 2017 Fredrik Lindqvist <https://github.im/Landrash>"

echo "Changing to homeassistant user"
sudo -u homeassistant -H /bin/bash << EOF

echo "Creating Home Assistant venv"
python3 -m venv /srv/homeassistant

echo "Changing to Home Assistant venv"
source /srv/homeassistant/bin/activate

echo "Install latest version of Home Assistant"
pip3 install homeassistant

echo "Deactivating virtualenv"
deactivate

echo "Downloading HASSbian helper scripts"
cd /home/pi
git clone https://github.com/home-assistant/hassbian-scripts.git

EOF

echo "Enable Home Assistant service"
systemctl enable home-assistant@homeassistant.service
sync

echo "Disable and remove Home Assitant install"
systemctl disable install_homeassistant
rm /etc/systemd/system/install_homeassistant.service
rm /usr/local/bin/install_homeassistant.sh
systemctl daemon-reload

echo "Start Home Assistant"
systemctl start home-assistant@homeassistant.service

echo "Installation done. To continue have a look at "
echo "If this script failed then this Raspberry Pi most likely did not have a fully functioning internet connection."
