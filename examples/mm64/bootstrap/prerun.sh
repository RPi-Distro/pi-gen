#!/bin/bash

set -eo pipefail

IGTOP=$(readlink -f $(dirname "$0"))

WORKROOT=${STAGE_WORK_DIR}


# TODO need top level selectors for:
#  external meta dir
#  external namespace for meta dir
#  external profile dir
#  external config dir


# Internalise directory structure variables
META=$(readlink -f $IGTOP/meta)
META_HOOKS=$(readlink -f $IGTOP/meta-hooks)
RPI_TEMPLATES=$(readlink -f $IGTOP/templates/rpi)
CONFIG_TOP=$(readlink -f $IGTOP/config)


# TODO get from top level arg, eg -p generic64-min-ab
INCONFIG=generic64-apt-ab

CONFIGF=$(readlink -f $CONFIG_TOP/${INCONFIG}.cfg)
test -s $CONFIGF || (echo config $CONFIGF is invalid; exit 1)

# Assemble bootstrap environment
ARGS_ENV=()
ARGS_ENV+=('--env' META_HOOKS=$META_HOOKS)
ARGS_ENV+=('--env' RPI_TEMPLATES=$RPI_TEMPLATES)

# TODO read options from input file
ARGS_ENV+=('--env' APT_PROXY=$APT_PROXY)
ARGS_ENV+=('--env' LOCALE_DEFAULT=$LOCALE_DEFAULT)
ARGS_ENV+=('--env' TIMEZONE_DEFAULT=$TIMEZONE_DEFAULT)
ARGS_ENV+=('--env' FIRST_USER_NAME=$FIRST_USER_NAME)
ARGS_ENV+=('--env' FIRST_USER_PASS=$FIRST_USER_PASS)


# Config defaults
IGconf_board=pi5


# Read and validate config
cfg_read_section image $CONFIGF
cfg_read_section system $CONFIGF
cfg_read_section machine $CONFIGF
[[ -z ${IGconf_layout+x} ]] && (echo config has no image layout; exit 1)
[[ -z ${IGconf_profile+x} ]] && (echo config has no profile; exit 1)

test -d $IGTOP/image/$IGconf_layout || (echo disk layout $IGconf_layout is invalid; exit 1)
test -s $IGTOP/image/$IGconf_layout/genimage.cfg.in || (echo $IGconf_layout has no genimage cfg; exit 1)
test -f $IGTOP/profile/$IGconf_profile || (echo profile $IGconf_profile is invalid; exit 1)
test -d $IGTOP/board/$IGconf_board || (echo board $IGconf_board is invalid; exit 1)


# Export this set of variables
export IGconf_board
export IGconf_layout
export IGconf_deploydir=$WORKROOT/deploy


# Assemble meta layers from profile
ARGS_LAYERS=()
while read -r line; do
   [[ "$line" =~ ^#.*$ ]] && continue
   [[ "$line" =~ ^$ ]] && continue
   test -f $META/$line.yaml || (echo invalid meta specifier: $line; exit 1)
   ARGS_LAYERS+=('--config' $META/$line.yaml)
done < $IGTOP/profile/$IGconf_profile


# Generate rootfs
podman unshare bdebstrap \
   "${ARGS_LAYERS[@]}" \
   "${ARGS_ENV[@]}" \
   --name $IMG_NAME \
   --hostname $TARGET_HOSTNAME \
   --output-base-dir ${WORKROOT}/bdebstrap \
   --target ${WORKROOT}/rootfs


# Apply rootfs overlays: image layout first then board
if [ -d $IGTOP/image/$IGconf_layout/rootfs-overlay ] ; then
   echo "$IGconf_layout:rootfs-overlay"
   rsync -a $IGTOP/image/$IGconf_layout/rootfs-overlay/ ${WORKROOT}/rootfs
fi
if [ -d $IGTOP/board/$IGconf_board/rootfs-overlay ] ; then
   echo "$IGconf_board:rootfs-overlay"
   rsync -a $IGTOP/board/$IGconf_board/rootfs-overlay/ ${WORKROOT}/rootfs
fi


# Run pre-genimage hooks: image layout first then board
if [ -x $IGTOP/image/$IGconf_layout/pre-image.sh ] ; then
   echo "$IGconf_layout:pre-image"
   $IGTOP/image/$IGconf_layout/pre-image.sh ${WORKROOT}/rootfs ${WORKROOT}
fi
if [ -x $IGTOP/board/$IGconf_board/pre-image.sh ] ; then
   echo "$IGconf_board:pre-image"
   $IGTOP/board/$IGconf_board/pre-image.sh ${WORKROOT}/rootfs ${WORKROOT}
fi


# Must exist
if [ ! -s ${WORKROOT}/genimage.cfg ] ; then
   echo "genimage config was not created - image generation is not possible"; exit 1
fi

GTMP=$(mktemp -d)
trap 'rm -rf $GTMP' EXIT
mkdir -p $IGconf_deploydir

# Generate image
podman unshare genimage \
   --rootpath ${WORKROOT}/rootfs \
   --tmppath $GTMP \
   --inputpath ${WORKROOT}   \
   --outputpath ${WORKROOT} \
   --loglevel=10 \
   --config ${WORKROOT}/genimage.cfg
