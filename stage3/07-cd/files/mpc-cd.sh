#!/bin/bash

ACTION="$1"
if [[ -z ${ACTION} ]]; then
	exit 1
fi

DEV="/dev/cdrom"
MPC="/usr/bin/mpc -p 6600"

do_mount() {
	NUM_TRACK=${ID_CDROM_MEDIA_TRACK_COUNT_AUDIO}
	if [[ -z ${NUM_TRACK} ]]; then
		/bin/echo "need udev to read track number"
		NUM_TRACK=$(/sbin/udevadm info --query=property ${DEV} | /bin/grep ID_CDROM_MEDIA_TRACK_COUNT_AUDIO | /usr/bin/awk -F= '{ print $2 }')
	fi
	/bin/echo "cd with ${NUM_TRACK} tracks detected"

	/bin/echo "clearing mpd queue"
	${MPC} clear

	for i in $(seq 1 ${NUM_TRACK}); do
		${MPC} add cdda:///${i}
	done
	${MPC} play
}

do_unmount() {
	${MPC} stop
	${MPC} -f "%position% %file%" playlist | /bin/grep cdda:// | /usr/bin/awk '{ print $1 }' | ${MPC} del
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
esac
