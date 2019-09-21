#!/bin/bash 

echo "Setup Machine:"
export MACHINE_ID=`ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}' | cut -d. -f4`
curl -X PUT http://raspi-manager:5984/machines/$MACHINE_ID -d " { \
\"IP\": \"`ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}'`\" , \
\"MAC\": \"`ifconfig eth0 | grep 'ether ' | cut  -f2 | awk '{ print $2}'`\" \
} "

cp /home/pi/rc.local /etc/rc.local