#!/bin/bash

#setup firewall
ufw allow ssh
ufw allow 5800
ufw allow 5900
ufw enable

#copy files from /boot for setup...
#hostname
#connection configuration
#clamav?
#apt/ansible?


