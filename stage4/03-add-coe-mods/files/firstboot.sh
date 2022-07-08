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
CONFIGFILE=/boot/thinclient-client.conf
if test -f "$CONFIGFILE"; then
  mv $CONFIGFILE /etc/thinclient-client.conf
fi

#network config
NETWORKFILE=/boot/net.cfg
if test -f "$NETWORKFILE"; then
  mv $NETWORKFILE /etc/dhcpcd.conf
  systemctl restart dhcpcd.service
fi

#clamav?

#ansible ssh auto login
KEYFILE=/boot/authorized_keys
if test -f "$KEYFILE"; then
  mkdir /home/tcadmin/.ssh
  mv $KEYFILE /home/tcadmin/.ssh/authorized_keys
  chown tcadmin /home/tcadmin/.ssh/authorized_keys
  chgrp tcadmin /home/tcadmin/.ssh/authorized_keys
fi

#set tcadmin password
PASSFILE=/boot/password
if test -f "$PASSFILE"; then
 chpasswd <<< "tcadmin:`cat $PASSFILE`"
fi 

#set x11vnc password
VNCPASSFILE=/boot/vncpass
if test -f "$VNCPASSFILE"; then
 x11vnc -storepasswd "`cat $VNCPASSFILE`" /etc/x11vnc.pass
else
 x11vnc -storepasswd "x11vnct3st" /etc/x11vnc.pass
fi 
chmod +r /etc/x11vnc.pass

#ntp servers?
