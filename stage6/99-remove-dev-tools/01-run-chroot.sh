#!/usr/bin/env bash
set -euo pipefail

apt remove -y --purge --autoremove $(cat /tmp/dev-tools)

rm -f /tmp/dev-tools /tmp/cmake_helper.sh
