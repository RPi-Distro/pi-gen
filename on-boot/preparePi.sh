#!/bin/bash 

sleep 30
echo "Setup Machine:" >> /home/pi/setup.log
export MACHINE_ID=`ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}' | cut -d. -f4`
curl -v -X PUT http://raspi-manager:5984/machines/$MACHINE_ID -d " { \
\"IP\": \"`ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}'`\" , \
\"MAC\": \"`ifconfig eth0 | grep 'ether ' | cut  -f2 | awk '{ print $2}'`\" \
} " >> /home/pi/setup.log

sleep 20 #wait network to be ready?
cp /home/pi/rc.local /etc/rc.local
curl http://raspi-manager/scripts/cluster-manager/scripts/setup-raspi.sh | bash >> /home/pi/setup.log

echo "End of setup" >> /home/pi/setup.log
