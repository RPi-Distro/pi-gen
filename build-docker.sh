#!/bin/bash -e
DOCKER="docker"
set +e
$DOCKER ps >/dev/null 2>&1
if [ $? != 0 ]; then
	DOCKER="sudo docker"
fi
if ! $DOCKER ps >/dev/null; then
	echo "error connecting to docker:"
	$DOCKER ps
	exit 1
fi
set -e

config_mount="/dev/null:/dev/null"
if [ -f config ]; then
	config_mount="$(pwd)/config:/pi-gen/config:ro"
	source config
fi

CONTAINER_NAME=${CONTAINER_NAME:-pigen_work}
CONTINUE=${CONTINUE:-0}

if [ "$*" != "" ] || [ -z "${IMG_NAME}" ]; then
	if [ -z "${IMG_NAME}" ]; then
		echo "IMG_NAME not set in 'build'" 1>&2
		echo 1>&2
	fi
	cat >&2 <<EOF
Usage:
    build-docker.sh [options]
Optional environment arguments: ( =<default> )
    CONTAINER_NAME=pigen_work  set a name for the build container
    CONTINUE=0                  continue from a previously started container
EOF
	exit 1
fi

CONTAINER_EXISTS=$($DOCKER ps -a --filter name="$CONTAINER_NAME" -q)
CONTAINER_RUNNING=$($DOCKER ps --filter name="$CONTAINER_NAME" -q)
if [ "$CONTAINER_RUNNING" != "" ]; then
	echo "The build is already running in container $CONTAINER_NAME. Aborting."
	exit 1
fi
if [ "$CONTAINER_EXISTS" != "" ] && [ "$CONTINUE" != "1" ]; then
	echo "Container $CONTAINER_NAME already exists and you did not specify CONTINUE=1. Aborting."
	echo "You can delete the existing container like this:"
	echo "  docker rm -v $CONTAINER_NAME"
	exit 1
fi

$DOCKER build -t pi-gen .
if [ "$CONTAINER_EXISTS" != "" ]; then
	trap "echo 'got CTRL+C... please wait 5s';docker stop -t 5 ${CONTAINER_NAME}_cont" SIGINT SIGTERM
	time $DOCKER run --rm --privileged \
		--volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
		-e IMG_NAME=${IMG_NAME}\
		pi-gen \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /pi-gen; ./build.sh;
	rsync -av work/*/build.log deploy/" &
	wait
else
	trap "echo 'got CTRL+C... please wait 5s'; docker stop -t 5 ${CONTAINER_NAME}" SIGINT SIGTERM
	$DOCKER run --name "${CONTAINER_NAME}" --privileged \
		-e IMG_NAME=${IMG_NAME}\
		-v "$(pwd)/deploy:/pi-gen/deploy" \
		-v "${config_mount}" \
		pi-gen \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /pi-gen; ./build.sh &&
	rsync -av work/*/build.log deploy/" &
	wait
fi
echo "Done! Your image(s) should be in deploy/"
