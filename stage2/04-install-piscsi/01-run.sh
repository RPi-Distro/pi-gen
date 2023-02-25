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
cd /home/pi/
git clone https://github.com/PiSCSI/piscsi.git
cd piscsi
echo $GITHUB_REF
git checkout $GITHUB_REF
git config --global user.email "noone@piscsi.com"
git config --global user.name "PiSCSI User"
echo "export CI=$CI"
echo "export GITHUB_REF=$GITHUB_REF"
# Cache the sudo credentials
echo raspberry | sudo -v -S
export CI=$CI
export GITHUB_REF=$GITHUB_REF
./easyinstall.sh --headless --cores=16 --run_choice=1
echo "easyinstal exited: $?"
EOF
