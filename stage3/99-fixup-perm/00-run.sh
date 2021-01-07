on_chroot << EOF
	chown -R ${FIRST_USER_NAME} /home/${FIRST_USER_NAME}
	chgrp -R ${FIRST_USER_NAME} /home/${FIRST_USER_NAME}
	# make conf files editable by pi user
	chown root:${FIRST_USER_NAME} /etc/jackdrc.conf
	chmod g+w /etc/jackdrc.conf
	chown root:${FIRST_USER_NAME} /etc/urlrelay/urlrelay.conf
	chmod g+w /etc/urlrelay/urlrelay.conf
	if ! grep -q "swappiness" /etc/sysctl.conf; then
		sudo echo "vm.swappiness = 10" >> /etc/sysctl.conf
	fi
	if ! grep -q "max_user_watches" /etc/sysctl.conf; then
		sudo echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf
	fi
EOF
