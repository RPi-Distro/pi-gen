#! /usr/bin/env bash

# Could move this type of setup to hooks
if [[ $LE_TRIGGERED_FROM_BUILD_ID ]]
then
  echo "--- Downloading debian package from Buildkite"
  buildkite-agent artifact download --build $LE_TRIGGERED_FROM_BUILD_ID 'dist/*.deb' .
  export LOCAL_KOLIBRI_PACKAGE=$PWD/dist/*.deb
else
  echo "Image will use Debian Package from Launchpad"
fi


if [[ $(docker ps -a | grep pi-gen) ]]
then
  echo "--- Building Pi Image with cache :money:"
  PRESERVE_CONTAINER=1 ./build-docker.sh
else
  echo "--- Building Pi Image"
  ./build-docker.sh
fi