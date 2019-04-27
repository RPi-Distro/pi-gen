#!/bin/bash -e

on_chroot << EOF
  curl -s https://bootstrap.pypa.io/get-pip.py | python

  # Fetch wait-for-it
  curl -s -o /tmp/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
  chmod +x /tmp/wait-for-it.sh

  git clone https://github.com/Screenly/screenly-ose.git /home/pi/screenly
  cd /home/pi/screenly
  git checkout production

  pip install -r requirements.txt
  mkdir -p /etc/ansible
  echo -e "[local]\nlocalhost ansible_connection=local" | tee /etc/ansible/hosts > /dev/null

  cd ansible
  HOME=/home/pi MANAGE_NETWORK=true ansible-playbook site.yml --skip-tags enable-ssl,disable-nginx,touches_boot_partition
  chown -R pi:pi /home/pi
  rm /home/pi/.screenly/initialized

  apt-get autoclean
  apt-get clean

  find /usr/share/doc -depth -type f ! -name copyright -delete
  find /usr/share/doc -empty -delete
  rm -rf /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian /usr/share/linda /var/cache/man
  find /usr/share/locale -type f ! -name 'en' ! -name 'de*' ! -name 'es*' ! -name 'ja*' ! -name 'fr*' ! -name 'zh*' -delete
  find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' ! -name 'de*' ! -name 'es*' ! -name 'ja*' ! -name 'fr*' ! -name 'zh*' -exec rm -r {} \;

  HOME=/home/pi python /home/pi/screenly/server.py &

  # Wait for server to start
  /tmp/wait-for-it.sh --host=127.0.0.1 --port=8080

  # Adds default assets
  /home/pi/screenly/bin/prepare_device_for_imaging.sh

  pkill -f server.py
  sleep 5
  chown -R pi:pi /home/pi

  rm /tmp/wait-for-it.sh
EOF
