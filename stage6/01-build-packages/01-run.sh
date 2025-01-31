#!/bin/bash -e


apt-get update;
xargs -a packages.txt apt-get install -y