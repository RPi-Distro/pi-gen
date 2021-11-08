#!/bin/bash -e

# https://raspberrypi.stackexchange.com/questions/8734/execute-script-on-start-up
# sudo crontab -e
# sudo nano /etc/rc.local

# https://unix.stackexchange.com/questions/187005/add-cron-job-via-single-command
# https://unix.stackexchange.com/questions/117244/installing-crontab-using-bash-script

# crontab -l | { cat; echo "@reboot python3 /home/pi/Desktop/exemple.py &"; } | crontab -
crontab -l | { cat; echo "@reboot sudo bash /script/script.sh > /dev/null 2>&1"; } | crontab -

