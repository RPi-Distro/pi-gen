#!/bin/bash

set -eo pipefail

# TODO need top level selectors for:
#  build artifact top dir
#  deploy dir
#  external meta dir
#  external namespace for meta dir
#  external profile dir

# TODO establish from dir layout / config
RPI_HOOKS=$(readlink -f ./hooks)
RPI_TEMPLATES=$(readlink -f ./templates/rpi)
META=$(readlink -f ./meta)
SLOTP_PROCESS=$(readlink -f ./image/slot-post-process.sh)

ARGS_ENV=()
ARGS_ENV+=('--env' RPI_HOOKS=$RPI_HOOKS)
ARGS_ENV+=('--env' RPI_TEMPLATES=$RPI_TEMPLATES)

# TODO establish from config parse
ARGS_ENV+=('--env' APT_PROXY=$APT_PROXY)
ARGS_ENV+=('--env' LOCALE_DEFAULT=$LOCALE_DEFAULT)
ARGS_ENV+=('--env' TIMEZONE_DEFAULT=$TIMEZONE_DEFAULT)
ARGS_ENV+=('--env' FIRST_USER_NAME=$FIRST_USER_NAME)
ARGS_ENV+=('--env' FIRST_USER_PASS=$FIRST_USER_PASS)

# TODO from profile
LAYERS="\
   ${RELEASE}/arm64/base-apt \
   rpi/${RELEASE}/arm64/apt \
   rpi/misc-utils \
   rpi/base/essential \
   rpi/boot-firmware \
   rpi/arm64/linux-image-v8 \
   rpi/user-credentials \
   rpi/misc-skel \
   sys-apps/systemd-net-min"

ARGS_LAYERS=()
for l in $LAYERS ; do
   test -f $META/$l.yaml || (echo $l is invalid; exit 1)
   ARGS_LAYERS+=('--config' $META/$l.yaml)
done

bdebstrap \
   "${ARGS_LAYERS[@]}" \
   "${ARGS_ENV[@]}" \
   --name $IMG_NAME \
   --hostname $TARGET_HOSTNAME \
   --output-base-dir ${STAGE_WORK_DIR}/bdebstrap \
   --target ${STAGE_WORK_DIR}/rootfs.tar.gz


cat << EOF > "${STAGE_WORK_DIR}/autoboot.txt"
[ALL]
boot_partition=2
EOF


# FIXME
FW_SIZE=60M
ROOT_SIZE=700M

cat image/genimage.cfg.in | sed \
   -e "s|<STAGE_WORK_DIR>|$STAGE_WORK_DIR|g" \
   -e "s|<IMG_NAME>|$IMG_NAME|g" \
   -e "s|<IMG_SUFFIX>|$IMG_SUFFIX|g" \
   -e "s|<IMG_FILENAME>|$IMG_FILENAME|g" \
   -e "s|<ARCHIVE_FILENAME>|$ARCHIVE_FILENAME|g" \
   -e "s|<FW_SIZE>|$FW_SIZE|g" \
   -e "s|<ROOT_SIZE>|$ROOT_SIZE|g" \
   -e "s|<ROOT_FEATURES>|'$ROOT_FEATURES'|g" \
   -e "s|<SLOTP>|'$SLOTP_PROCESS'|g" \
   > ${STAGE_WORK_DIR}/genimage.cfg


rm -rf ${STAGE_WORK_DIR}/genimage.tmp
rm -rf ${STAGE_WORK_DIR}/rootfs
mkdir ${STAGE_WORK_DIR}/rootfs

podman --log-level debug unshare fakeroot tar -C ${STAGE_WORK_DIR}/rootfs -xzf ${STAGE_WORK_DIR}/rootfs.tar.gz

podman --log-level debug unshare genimage \
   --rootpath ${STAGE_WORK_DIR}/rootfs \
   --tmppath ${STAGE_WORK_DIR}/genimage.tmp \
   --inputpath ${STAGE_WORK_DIR}   \
   --outputpath ${STAGE_WORK_DIR} \
   --loglevel=10 \
   --config ${STAGE_WORK_DIR}/genimage.cfg
