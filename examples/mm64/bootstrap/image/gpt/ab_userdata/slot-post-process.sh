#!/bin/bash -e

set -u

SLOT=$1
DISKLABEL=$2

echo "pre-process $IMAGEMOUNTPATH for slot ${SLOT}" 1>&2

case $DISKLABEL in
   ROOT*)
      cat << EOF > $IMAGEMOUNTPATH/etc/fstab
/dev/disk/by-label/ROOT${SLOT} /               ext4 rw,relatime,errors=remount-ro 0 1
/dev/disk/by-label/BOOT${SLOT} /boot/firmware  vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro 0 2
/dev/disk/by-label/USERDATA    /data           ext4 rw,relatime 0 2
/dev/disk/by-label/BOOTFS      /bootfs         vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro 0 2
EOF
      ;;
   BOOT*)
      sed -i "s|root=\([^ ]*\)|root=\/dev\/disk\/by-label\/ROOT$SLOT|" $IMAGEMOUNTPATH/cmdline.txt
      ;;
   *)
      ;;
esac
