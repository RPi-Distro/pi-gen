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

if [ -f config ]; then
	# shellcheck disable=SC1091
	source config
fi


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_LIST=${STAGE_LIST:-${BASE_DIR}/stage*}
IMAGE_NAME=${IMAGE_NAME:-pikube_gen}


echo "Building base image..."
${DOCKER} build -t ${IMAGE_NAME}:init "${DIR}"


PREVIOUS_IMAGE=${IMAGE_NAME}:init

for STAGE_DIR in $STAGE_LIST; do
    STAGE_NAME=$(basename $STAGE_DIR)
    CONTAINER_NAME=${IMAGE_NAME}_${STAGE_NAME}

    BASE_IMAGE_NAME="${IMAGE_NAME}:${STAGE_NAME}_base"

BEFORE_BUILD_ID=$(docker inspect --format {{.Id}} ${BASE_IMAGE_NAME}  || echo "noexists")
docker build --rm -t ${IMAGE_NAME}:${STAGE_NAME}_base -f- $STAGE_DIR <<EOF
    FROM ${PREVIOUS_IMAGE}

    COPY . /pi-gen/${STAGE_NAME}/

    CMD dpkg-reconfigure qemu-user-static && ./build.sh && touch ${STAGE_NAME}/SKIP
EOF

    AFTER_BUILD_ID=$(docker inspect --format {{.Id}} ${BASE_IMAGE_NAME})

    if [ "$AFTER_BUILD_ID" != "$BEFORE_BUILD_ID" ]; then
        echo "doing it"
        docker run -v ${DIR}/deploy:/pi-gen/deploy --name ${CONTAINER_NAME} --privileged ${BASE_IMAGE_NAME} || echo "${STAGE_NAME} Failed!"
        ${DOCKER} commit ${IMAGE_NAME}_${STAGE_NAME} ${IMAGE_NAME}:${STAGE_NAME}
        docker rm ${CONTAINER_NAME} 
    fi

    PREVIOUS_IMAGE=${IMAGE_NAME}:${STAGE_NAME}
done