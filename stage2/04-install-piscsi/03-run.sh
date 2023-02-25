#!/bin/bash -e

pwd
echo "Base dir: $BASE_DIR"

source $BASE_DIR/config

CI=true

echo "Github Reference is $GITHUB_REF"
#If Github Reference is not set, assign it to 'develop'
GITHUB_REF="${GITHUB_REF:=develop}"
echo "Github Reference is $GITHUB_REF"
echo "CI is $CI"

on_chroot << EOF
su pi
cd /home/pi/piscsi/python/web
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
deactivate
git rev-parse HEAD > current

cd /home/pi/piscsi/python/ctrlboard
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
deactivate

cd /home/pi/piscsi/python/ctrlboard
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
deactivate
EOF



