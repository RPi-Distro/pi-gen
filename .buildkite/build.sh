#! /usr/bin/env bash

# Could move this type of setup to hooks
if [[ $LE_TRIGGERED_FROM_BUILD_ID ]]
then
  echo "--- Downloading debian package from Buildkite"
  buildkite-agent artifact download --build $LE_TRIGGERED_FROM_BUILD_ID 'dist/*.deb' .
  DOCKER_RUN_OPTS="-v $PWD/dist/:/dist:ro"
else
  echo "Image will use Debian Package from Launchpad"
fi

echo "--- Building Pi Image"
PRESERVE_CONTAINER=1 CONTINUE=1 ./build-docker.sh