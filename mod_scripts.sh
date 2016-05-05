#!/bin/bash

find ./ -path ./work -prune -o -name "*.sh" -exec chmod +x {} \;
