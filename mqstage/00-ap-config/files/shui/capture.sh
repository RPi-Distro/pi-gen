#!/bin/sh
raspistill -tl 1000 -t 0 -rot 180 -o /home/pi/captures/img%04d.jpg
