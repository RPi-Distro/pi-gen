#!/bin/bash

mkdir -p owrx/work owrx/deploy
DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

# use more cores (leaving 4 for the system)
MAKEFLAGS="-j$(nproc --ignore 4)"

#if ! type jq 1>/dev/null 2>&1; then
#	echo "This script requires 'jq' command."
#	exit 1
#fi

get_owrxp_version() {
	curl -s -L -H "Accept: application/vnd.github+json" https://api.github.com/repos/luarvique/ppa/contents/bookworm/arm64 |
		grep -E 'name.*openwebrx_[^_]+_.*' |
		cut -d'_' -f 2 |
		sort -V |
		tail -1
	#jq -r '.[] | select(.name | contains("openwebrx_")) | .name' |
}

VER=$(get_owrxp_version)

echo "Building RPI-64bit image for OpenWebRX+ v${VER}"
echo "IMG_SUFFIX=\"-64bit-v${VER}\"" > stage7/EXPORT_IMAGE

# preserve the container after the build, so we can add new stuff after a successful build
echo
echo "trying to continue previous build..."
echo "if you want to restart the build from the beginning:"
echo "sudo rm -rf owrx; docker rm -v pigen_work"
echo;echo;echo

set -euxo pipefail
sudo \
CONTINUE=1 \
PRESERVE_CONTAINER=1 \
PIGEN_DOCKER_OPTS="-e MAKEFLAGS=${MAKEFLAGS} -v ${DIR}/owrx/work:/pi-gen/work -v ${DIR}/owrx/deploy:/pi-gen/deploy" \
./build-docker.sh

