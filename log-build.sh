#!/bin/bash
date=$(date +'%d-%m_%I:%M')
lognm="build-"
lognm+="$date"
lognm+=".log"
script "$lognm"
