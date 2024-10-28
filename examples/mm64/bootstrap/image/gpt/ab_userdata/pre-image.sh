#!/bin/sh

image_top=$(readlink -f $(dirname "$0"))
rootfs=$1
genimg_in=$2

# This disk layout requires two files which are pulled in via genimage cfg:
#  autoboot.txt - used for indicating the default boot partition
#  tryboot.txt - used for tryboot

cat << EOF > "${genimg_in}/autoboot.txt"
[ALL]
boot_partition=2
EOF

# Relates directly to the layout in genimage.cfg.in
cat << EOF > "${genimg_in}/tryboot.txt"
[all]
tryboot_a_b=1
boot_partition=2
[tryboot]
boot_partition=4
EOF


# Generate the config for genimage to ingest:
# FIXME - calc dynamically
FW_SIZE=60M
ROOT_SIZE=700M

SLOTP_PROCESS=$(readlink -f ${image_top}/slot-post-process.sh)

cat $image_top/genimage.cfg.in | sed \
   -e "s|<DEPLOY_DIR>|$IGconf_deploydir|g" \
   -e "s|<IMAGE_NAME>|${IGconf_board}-ab|g" \
   -e "s|<FW_SIZE>|$FW_SIZE|g" \
   -e "s|<ROOT_SIZE>|$ROOT_SIZE|g" \
   -e "s|<SLOTP>|'$SLOTP_PROCESS'|g" \
   > ${genimg_in}/genimage.cfg

