#!/bin/bash -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BUILD_OPTS="$*"

DOCKER=${DOCKER:-docker}

if ! ${DOCKER} ps >/dev/null 2>&1; then
	DOCKER="sudo docker"
fi
if ! ${DOCKER} ps >/dev/null; then
	echo "error connecting to docker:"
	${DOCKER} ps
	exit 1
fi

CONFIG_FILE=""

# Arguments passed on command line have highest priority (others are fallbacks)
while getopts "c:" flag
do
	case "${flag}" in
		c)
			CONFIG_FILE="${OPTARG}"
			;;
		*)
			;;
	esac
done

if [ -z "${CONFIG_FILE}" ]; then # config file not yet defined
	if [ -f "${DIR}/config" ]; then # guess location relative to this script
		CONFIG_FILE="${DIR}/config"
	fi
fi

# Ensure that the configuration file is present
if test -z "${CONFIG_FILE}"; then
	echo "Configuration file need to be present in '${DIR}/config' or path passed as parameter"
	exit 1
fi
CONFIG_FILE_ORG_DIR="$(dirname "${CONFIG_FILE}")"

source "${CONFIG_FILE}"

CONTAINER_NAME=${CONTAINER_NAME:-pigen_work}
CONTINUE=${CONTINUE:-0}
PRESERVE_CONTAINER=${PRESERVE_CONTAINER:-0}

if [ -z "${IMG_NAME}" ]; then
	echo "IMG_NAME not set in 'config'" 1>&2
	echo 1>&2
	exit 1
fi

# Ensure the Git Hash is recorded before entering the docker container
GIT_HASH=${GIT_HASH:-"$(git rev-parse HEAD)"}

CONTAINER_EXISTS=$(${DOCKER} ps -a --filter name="${CONTAINER_NAME}" -q)
CONTAINER_RUNNING=$(${DOCKER} ps --filter name="${CONTAINER_NAME}" -q)
if [ "${CONTAINER_RUNNING}" != "" ]; then
	echo "The build is already running in container ${CONTAINER_NAME}. Aborting."
	exit 1
fi
if [ "${CONTAINER_EXISTS}" != "" ] && [ "${CONTINUE}" != "1" ]; then
	echo "Container ${CONTAINER_NAME} already exists and you did not specify CONTINUE=1. Aborting."
	echo "You can delete the existing container like this:"
	echo "	${DOCKER} rm -v ${CONTAINER_NAME}"
	exit 1
fi

# Modify original build-options to allow config file to be mounted in the docker container
BUILD_OPTS="$(echo "${BUILD_OPTS:-}" | sed -E 's@\-c\s+?([^ ]+)@@')"

# Check the arch of the machine we're running on. If it's 64-bit, use a 32-bit base image instead
case "$(uname -m)" in
	x86_64|aarch64)
		BASE_IMAGE=i386/debian:buster
		;;
	*)
		BASE_IMAGE=debian:buster
		;;
esac

# Build the pi-gen image
${DOCKER} build --build-arg BASE_IMAGE=${BASE_IMAGE} -t pi-gen "${DIR}"

# Create the pi-gen container
if [ "${CONTAINER_EXISTS}" != "" ]; then
	CONTAINER_ID=$(
		${DOCKER} create \
			--rm \
			--name "${CONTAINER_NAME}_cont" \
			--privileged \
			-e "GIT_HASH=${GIT_HASH}" \
			--volumes-from="${CONTAINER_NAME}" \
			pi-gen \
			bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
		cd /pi-gen; ./build.sh ${BUILD_OPTS} &&
		rsync -av work/*/build.log deploy/"
	)
else
	CONTAINER_ID=$(
		${DOCKER} create \
			--name "${CONTAINER_NAME}" \
			--privileged \
			-e "GIT_HASH=${GIT_HASH}" \
			pi-gen \
			bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
		cd /pi-gen; ./build.sh ${BUILD_OPTS} &&
		rsync -av work/*/build.log deploy/"
	)
fi

# Create a temporary working dir for file tweaks prior to copying into container
PIGEN_TMP_DIR="$(mktemp -d -p "" pi-gen.XXXXXX)" || { echo "Failed to create temp dir"; exit 1; }

finish() {
	rm -rf "$PIGEN_TMP_DIR"
}

trap finish EXIT

cp "${CONFIG_FILE}" "${PIGEN_TMP_DIR}"/config

OPTIONAL_EXT_CONFIGS=(
CUSTOM_LIST
CUSTOM_LIST_DIR
)

# Add optional config files to target area
pushd "${CONFIG_FILE_ORG_DIR}" >/dev/null || { echo "Unable to cd to ${CONFIG_FILE_ORG_DIR}" 1>&2; exit 1; }
for ext_config_item in ${OPTIONAL_EXT_CONFIGS[@]}; do
	# Skip undefined ext configs
	if [ -z ${!ext_config_item+x} ]; then
		continue
	fi

	declare "${ext_config_item}"="${!ext_config_item//$'\r'}" # remove any trailing carriage returns

	if [ ! -e ${!ext_config_item} ]; then
		echo "The target of config item $ext_config_item (${!ext_config_item}) does not exist" 1>&2
		exit 1
	fi

	target_config_path=/pi-gen/"${ext_config_item,,}"

	# Tweak config file path to ext config
	sed -i -E 's@('"$ext_config_item"=').*@\1'"$target_config_path"'@' "${PIGEN_TMP_DIR}"/config

	# Copy file into container
	${DOCKER} cp "${!ext_config_item}" "$CONTAINER_ID":"${target_config_path}"
done
popd >/dev/null

${DOCKER} cp "${PIGEN_TMP_DIR}"/config "$CONTAINER_ID":/pi-gen/config

# Start a pi-gen container
trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_ID}' SIGINT SIGTERM
time ${DOCKER} start -a "$CONTAINER_ID" &
wait "$!"

echo "copying results from deploy/"
${DOCKER} cp "${CONTAINER_NAME}":/pi-gen/deploy .
ls -lah deploy

# cleanup
if [ "${PRESERVE_CONTAINER}" != "1" ]; then
	${DOCKER} rm -v "${CONTAINER_NAME}"
fi

echo "Done! Your image(s) should be in deploy/"
