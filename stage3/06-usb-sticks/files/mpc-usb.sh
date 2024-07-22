#!/bin/bash

ACTION=$1
DEVICE=$2
MPDPORT=6600
MPC="/usr/bin/mpc -p ${MPDPORT}"

MOUNT_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')
LABEL=$(/usr/bin/basename ${MOUNT_POINT})

do_mount() {
    /bin/echo "clearing previous queue"
    ${MPC} clear
    /bin/echo "updating mpd database..."
    ${MPC} update --wait
    /bin/echo "adding ${LABEL} files to queue"
    ${MPC} add ${LABEL}
    /bin/echo "playing queue"
    ${MPC} play
}

do_unmount() {
    /bin/echo "clearing previous queue from ${LABEL} files"
    ${MPC} -f "%position% %file%" playlist | /bin/grep ${LABEL} | /usr/bin/awk '{ print $1 }' | ${MPC} del
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
esac
