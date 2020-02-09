#!/bin/bash
set -e

# lock dirs/files
LOCKFILE="/etc/iot-setup-lock"

# Forces hostname to be the serial number of the device
set-hostname() {
	CURRENT_HOSTNAME=`hostname`
	SERIAL_NUMBER=$(grep -Po '^Serial\s*:\s*\K[[:xdigit:]]{16}' /proc/cpuinfo)

	if [ "x${CURRENT_HOSTNAME}" != "x${SERIAL_NUMBER}" ] ; then
		echo $SERIAL_NUMBER | tee /etc/hostname
		sed -i 's/^127\.0\.1\.1/# 127\.0\.1\.1/g' /etc/hosts 
		echo "127.0.1.1    $SERIAL_NUMBER" | tee -a /etc/hosts 
	fi

	return "${SERIAL}"
}

# request-iot-package() {
# 	SERIAL="$1"
# 	curl -q -XGET http://frontend.hitachi.net/register?serial="$SERIAL"
# }

# download-iot-package() {
# 	DL_URL="$1"
# 	ATTEMPT=0
# 	RETRIES=10

# 	while [ ${ATTEMPT} -lt ${RETRIES} ]; do
# 		curl -q -XGET "${DL_URL}" -o package.tgz && break
# 		ATTEMPT=${ATTEMPT}+1
# 		sleep 30
# 	done
# }

# Only runs if we are at first boot
run-if-unlocked() {
	[ -f "${LOCKFILE}" ] || run "$@"
}

# Creates the lock file
set-lock-file() {
	touch "${LOCKFILE}"
}

# Default run
run() {
	SERIAL=$(set-hostname)
	# DL_URL=$(request-iot-package)
	# download-iot-package ${DL_URL} && {
		set-lock-file 
		reboot now
	} || {
		logger ERROR "Impossible to setup device ${SERIAL} via ${DL_URL}. Waiting for Human to fix"
	}
}

# By default executes from here
run-if-unlocked
