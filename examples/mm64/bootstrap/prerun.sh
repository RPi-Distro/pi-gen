#!/bin/bash

set -eo pipefail

mkdir -p ${STAGE_WORK_DIR}/rootfs

# TODO need top level selectors for:
#  build artifact top dir
ARTIFACT_OUT_DIR=$STAGE_WORK_DIR
#  deploy dir
#  external meta dir
#  external namespace for meta dir
#  external profile dir

# TODO establish from dir layout
RPI_HOOKS=$(readlink -f ./hooks)
RPI_TEMPLATES=$(readlink -f ./templates/rpi)
META=$(readlink -f ./meta)

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
   --target ${STAGE_WORK_DIR}/rootfs
