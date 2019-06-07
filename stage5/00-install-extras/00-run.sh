#!/bin/bash -e

on_chroot << EOF
apt-get install openjdk-11-jre-headless -y --no-install-recommends
#update-binfmts --package openjdk-11 --remove jar /usr/bin/jexec
apt-get purge openjdk-11-jre-headless openjdk-8-jre-headless+ -y
apt-mark auto openjdk-8-jre-headless
EOF
