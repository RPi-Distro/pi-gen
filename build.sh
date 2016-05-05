#!/bin/bash -e

##---------------------------
## Functions
##---------------------------

run_sub_stage()
{
	log "Begin ${SUB_STAGE_DIR}"

	pushd ${SUB_STAGE_DIR} > /dev/null
	
	# Loop through each substage
	for i in {00..99}; do
	
		# Check for debconf stage
		if [ -f ${i}-debconf ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-debconf"
			on_chroot sh -e - << EOF
debconf-set-selections <<SELEOF
`cat ${i}-debconf`
SELEOF
EOF
		log "End ${SUB_STAGE_DIR}/${i}-debconf"
		fi
		
		# Install any packages with no-install-recommends set
		if [ -f ${i}-packages-nr ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages-nr"
			PACKAGES=`cat $i-packages-nr | tr '\n' ' '`
			if [ -n "$PACKAGES" ]; then
				on_chroot sh -e - << EOF
apt-get install --no-install-recommends -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages-nr"
		fi
		
		# Install any packages normally
		if [ -f ${i}-packages ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages"
			PACKAGES=`cat $i-packages | tr '\n' ' '`
			if [ -n "$PACKAGES" ]; then
				on_chroot sh -e - << EOF
apt-get install -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages"
		fi
		
		# Apply any patches
		if [ -d ${i}-patches ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-patches"
			pushd ${STAGE_WORK_DIR} > /dev/null
			if [ "${CLEAN}" = "1" ]; then
				rm -rf .pc
				rm -rf *-pc
			fi
			QUILT_PATCHES=${SUB_STAGE_DIR}/${i}-patches
			mkdir -p ${i}-pc
			ln -sf .pc ${i}-pc
			if [ -e ${SUB_STAGE_DIR}/${i}-patches/EDIT ]; then
				echo "Dropping into bash to edit patches..."
				bash
			fi
			RC=0
			quilt push -a || RC=$?
			case "$RC" in
				0|2)
					;;
				*)
					false
					;;
			esac
			popd > /dev/null
			log "End ${SUB_STAGE_DIR}/${i}-patches"
		fi
		
		# Run the substages run script
		if [ -x ${i}-run.sh ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run.sh"
			./${i}-run.sh
			log "End ${SUB_STAGE_DIR}/${i}-run.sh"
		fi
		
		# Run the substages chroot script
		if [ -f ${i}-run-chroot ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run-chroot"
			on_chroot sh -e - < ${i}-run-chroot
			log "End ${SUB_STAGE_DIR}/${i}-run-chroot"
		fi
	done
	popd > /dev/null
	log "End ${SUB_STAGE_DIR}"
}

run_stage(){
	log "Begin ${STAGE_DIR}"
	
	pushd ${STAGE_DIR} > /dev/null
	
	# Unmount this stage's folder on the filesystem
	unmount ${WORK_DIR}/${STAGE}
	
	# Set the working directory for this stage
	STAGE_WORK_DIR=${WORK_DIR}/${STAGE}
	
	# Set the root directory for this stage
	ROOTFS_DIR=${STAGE_WORK_DIR}/rootfs
	
	# Check to see if we should skip this stage (seemingly never)
	if [ ! -f SKIP ]; then
	
		# Clean the rootfs, if requested
		if [ "${CLEAN}" = "1" ]; then
			if [ -d ${ROOTFS_DIR} ]; then
				rm -rf ${ROOTFS_DIR}
			fi
		fi
		
		# Run the pre-run script
		if [ -x prerun.sh ]; then
			log "Begin ${STAGE_DIR}/prerun.sh"
			./prerun.sh
			log "End ${STAGE_DIR}/prerun.sh"
		fi
		
		# For each substage, run the run_sub_stage command for it
		for SUB_STAGE_DIR in ${STAGE_DIR}/*; do
			if [ -d ${SUB_STAGE_DIR} ]; then
				run_sub_stage
			fi
		done
	fi
	
	# Unmount the stag again
	unmount ${WORK_DIR}/${STAGE}
	
	# Set the previous stage info to this stage for the next stage to use
	PREV_STAGE=${STAGE}
	PREV_STAGE_DIR=${STAGE_DIR}
	PREV_ROOTFS_DIR=${ROOTFS_DIR}
	
	popd > /dev/null
	
	log "End ${STAGE_DIR}"
}



##---------------------------
## Start Build
##---------------------------

# Require Root to run
if [ "$(id -u)" != "0" ]; then
	echo "Please run as root" 1>&2
	exit 1
fi

# Handle input options
for i in "$@"
do
case $i in

    --imagename=*)      
    IMG_NAME="${i#*=}"
    shift
    ;;

    # Username to use in rootfs
    --username=*)      
    USER_NAME="${i#*=}"
    shift
    ;;
	
	# Hostname to use in rootfs
    --password=*)      
    PASS_WORD="${i#*=}"
    shift
    ;;
    
    # Hostname to use in rootfs
    --hostname=*)      
    HOST_NAME="${i#*=}"
    shift
    ;;
    
    # unknown option
    *)        
    ;;
esac
done

if [ -z "${IMG_NAME}" ]; 
then
	echo "No image name specified, defaulting to \"raspbian\""
	IMG_NAME="raspbian"
fi

if [ -z "$USER_NAME" ]
then
  echo "No username specified, defaulting to \"pi\""
  USER_NAME="pi"
fi

if [ -z "$PASS_WORD" ]
then
  echo "No username specified, defaulting to \"raspberry\""
  PASS_WORD="raspberry"
fi

if [ -z "$HOST_NAME" ]
then
  echo "No hostname specified, defaulting to \"raspberrypi\""
  HOST_NAME="raspberrypi"
fi

# Source a config file if it exists
if [ -f config ]; then
	source config
fi

# Set and export other env variables
export USER_NAME
export HOST_NAME
export PASS_WORD
export IMG_NAME

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR="${BASE_DIR}/scripts"
export WORK_DIR="${BASE_DIR}/work/${IMG_NAME}"
export LOG_FILE="${WORK_DIR}/build.log"

export CLEAN
export APT_PROXY

export STAGE
export PREV_STAGE
export STAGE_DIR
export PREV_STAGE_DIR
export ROOTFS_DIR
export PREV_ROOTFS_DIR

export QUILT_PATCHES
export QUILT_NO_DIFF_INDEX=1
export QUILT_NO_DIFF_TIMESTAMPS=1
export QUILT_REFRESH_ARGS="-p ab"

source ${SCRIPT_DIR}/common
export -f log
export -f bootstrap
export -f unmount
export -f on_chroot
export -f copy_previous
export -f update_issue

# Create working directory
mkdir -p ${WORK_DIR}
log "Begin ${BASE_DIR}"

# Successively build each stage
for STAGE_DIR in ${BASE_DIR}/stage*; do
	STAGE=$(basename ${STAGE_DIR})
	run_stage
done

log "End ${BASE_DIR}"
