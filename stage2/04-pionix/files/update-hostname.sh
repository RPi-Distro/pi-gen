#!/bin/bash
cd /tmp
/usr/bin/hostname -F /etc/hostname
HN=`hostname`
echo Current hostname $HN
#cp /etc/hostname /tmp
sudo echo belay-`cat /sys/class/net/eth0/address | awk '{split($0,a,":"); print a[5] a[6]}'` > /tmp/hostname
NHN=`cat /tmp/hostname`
echo New hostname $NHN
#cp -a /etc/hosts_factory_default /mnt/user_data/etc/hosts
/usr/bin/sed -i "s/$HN/$NHN/g" /etc/hosts
/usr/bin/cp /tmp/hostname /etc
/usr/bin/hostname -F /etc/hostname

