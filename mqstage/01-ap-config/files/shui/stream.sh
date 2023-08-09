#!/bin/bash
raspivid -rot 90 -o - -t 0 -fps 24 | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://0.0.0.0:8554}' :demux=h264

