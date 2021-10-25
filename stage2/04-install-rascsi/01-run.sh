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
git clone https://github.com/akuker/RASCSI.git
cd RASCSI
echo $GITHUB_REF
git checkout $GITHUB_REF
git config --global user.email "user@rascsi.com"
git config --global user.name "RaSCSI User"
echo "export CI=$CI"
echo "export GITHUB_REF=$GITHUB_REF"
export CI=$CI
export GITHUB_REF=$GITHUB_REF
./easyinstall.sh -r=1
echo "easyinstal exited: $?"
EOF
