#!/bin/bash




#setup firewall
ufw allow ssh
ufw allow 5800
ufw allow 5900
ufw enable

#copy files from /boot for setup...
#hostname
HOSTFILE=/boot/hostname
if test -f "$HOSTFILE"; then
  mv $HOSTFILE /etc/hostname
  # todo - need to update /etc/hosts
fi

#connection configuration
CONFIGFILE=/boot/coe-client.conf
if test -f "$CONFIGFILE=/boot/coe-client.conf
"; then
  mv $CONFIGFILE=/boot/coe-client.conf
 /etc/coe-client.conf
fi

#clamav?
#apt/ansible?

#ntp servers?
