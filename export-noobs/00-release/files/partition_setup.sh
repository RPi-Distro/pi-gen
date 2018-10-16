#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ]; then
  printf "Error: missing environment variable part1 or part2\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1 /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

sed /tmp/1/cmdline.txt -i -e "s|root=[^ ]*|root=${part2}|"
sed /tmp/2/etc/fstab -i -e "s|^.* / |${part2}  / |"
sed /tmp/2/etc/fstab -i -e "s|^.* /boot |${part1}  /boot |"

if [ -f /mnt/ssh ]; then
  cp /mnt/ssh /tmp/1/
fi

if [ -f /mnt/ssh.txt ]; then
  cp /mnt/ssh.txt /tmp/1/
fi

if [ -f /settings/wpa_supplicant.conf ]; then
  cp /settings/wpa_supplicant.conf /tmp/1/
fi

if ! grep -q resize /proc/cmdline; then
  sed -i 's| init=/usr/lib/raspi-config/init_resize.sh||;s| quiet||2g' /tmp/1/cmdline.txt
fi

umount /tmp/1
umount /tmp/2
