#!/bin/bash -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BUILD_OPTS="$*"

DOCKER="docker"

if ! ${DOCKER} ps >/dev/null 2>&1; then
	DOCKER="sudo docker"
fi
if ! ${DOCKER} ps >/dev/null; then
	echo "error connecting to docker:"
	${DOCKER} ps
	exit 1
fi

CONFIG_FILE=""
if [ -f "${DIR}/config" ]; then
	CONFIG_FILE="${DIR}/config"
fi

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

# Ability to pass in name=value pairs that will be available to config
# as well as sent to the docker run command as environment variables.
# This is so we can use command line arguments (or workflow secrets)
# to build a ready-to-use image without mucking around with saved configs
# and thus expose private information

# Get rest of unparsed arguments
shift $(expr $OPTIND - 1 )

# Convert it into an array
ADDL_ENV=()
while test $# -gt 0; do
  ADDL_ENV+=("$1")
  shift
done

# Parse key=value pairs and export them
while IFS='=' read -r name value; do
  # Handle double-quoted ("...") values.
  if [[ $value =~ ^\"(.*)\"$ ]]; then
    # Using `read` without `-r` removes the \ from embedded \<char> sequences.
    IFS= read value <<<"${BASH_REMATCH[1]}"
  fi
  # Export so config can access these values
  export "${name}=${value}"
done <<< $( IFS=$'\n'; echo "${ADDL_ENV[*]}" )

# Ensure that the configuration file is an absolute path
if test -x /usr/bin/realpath; then
	CONFIG_FILE=$(realpath -s "$CONFIG_FILE" || realpath "$CONFIG_FILE")
fi

# Ensure that the confguration file is present
if test -z "${CONFIG_FILE}"; then
	echo "Configuration file need to be present in '${DIR}/config' or path passed as parameter"
	exit 1
else
	# shellcheck disable=SC1090
	source ${CONFIG_FILE}
fi

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
	echo "  ${DOCKER} rm -v ${CONTAINER_NAME}"
	exit 1
fi

# Modify original build-options to allow config file to be mounted in the docker container
BUILD_OPTS="$(echo "${BUILD_OPTS:-}" | sed -E 's@\-c\s?([^ ]+)@-c /config@')"

# Check the arch of the machine we're running on. If it's 64-bit, use a 32-bit base image instead
case "$(uname -m)" in
  x86_64|aarch64)
    BASE_IMAGE=i386/debian:buster
    ;;
  *)
    BASE_IMAGE=debian:buster
    ;;
esac
${DOCKER} build --build-arg BASE_IMAGE=${BASE_IMAGE} -t pi-gen "${DIR}"

# Ability to add additional mounts so that custom stages can be mounted into the build process
# without modifying the pi-gen repository
DOCKER_ADDL_MOUNTS=""
echo "Processing additional mounts..."
for mount in ${ADDL_MOUNTS:=""}
do
	DOCKER_ADDL_MOUNTS="${DOCKER_ADDL_MOUNTS} --volume ${mount}"
done

# Pass in any additional env that we were given to the docker run commands
DOCKER_ADDL_ENV=
while IFS='=' read -r name value; do
  # Handle double-quoted ("...") values.
  if [[ $value =~ ^\"(.*)\"$ ]]; then
    # Using `read` without `-r` removes the \ from embedded \<char> sequences.
    IFS= read value <<<"${BASH_REMATCH[1]}"
  fi
  # Append to a string in docker env format
  DOCKER_ADDL_ENV="${DOCKER_ADDL_ENV} -e ${name}=${value}"
done <<< $( IFS=$'\n'; echo "${ADDL_ENV[*]}" )

if [ "${CONTAINER_EXISTS}" != "" ]; then
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}_cont' SIGINT SIGTERM
	time ${DOCKER} run --rm --privileged \
		--cap-add=ALL \
		-v /dev:/dev \
		-v /lib/modules:/lib/modules \
		--volume "${CONFIG_FILE}":/config:ro \
		${DOCKER_ADDL_MOUNTS} \
		${DOCKER_ADDL_ENV} \
		-e "GIT_HASH=${GIT_HASH}" \
		--volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
		pi-gen \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /pi-gen; ./build.sh ${BUILD_OPTS} &&
	rsync -av work/*/build.log deploy/" &
	wait "$!"
else
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}' SIGINT SIGTERM
	time ${DOCKER} run --name "${CONTAINER_NAME}" --privileged \
		--cap-add=ALL \
		-v /dev:/dev \
		-v /lib/modules:/lib/modules \
		--volume "${CONFIG_FILE}":/config:ro \
		${DOCKER_ADDL_MOUNTS} \
		${DOCKER_ADDL_ENV} \
		-e "GIT_HASH=${GIT_HASH}" \
		pi-gen \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /pi-gen; ./build.sh ${BUILD_OPTS} &&
	rsync -av work/*/build.log deploy/" &
	wait "$!"
fi

echo "copying results from deploy/"
${DOCKER} cp "${CONTAINER_NAME}":/pi-gen/deploy .
ls -lah deploy

# cleanup
if [ "${PRESERVE_CONTAINER}" != "1" ]; then
	${DOCKER} rm -v "${CONTAINER_NAME}"
fi

echo "Done! Your image(s) should be in deploy/"
