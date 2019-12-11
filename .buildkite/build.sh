#! /usr/bin/env bash

if [[ $LE_TRIGGERED_FROM_BUILD_ID ]]
then
  buildkite-agent artifact download --build $LE_TRIGGERED_FROM_BUILD_ID 'dist/*.deb' .
fi

./build-docker.sh