#!/bin/bash -e

HASH=`wget https://api.github.com/repos/KenT2/python-games/git/refs/heads/master -qO -| grep \"sha\" | cut -f 2 -d ':' | cut -f 2 -d \"`

if [ -f files/python_games.hash ]; then
	HASH_LOCAL=`cat files/python_games.hash`
fi

if [ ! -e files/python_games.tar.gz ] || [ "$HASH" != "$HASH_LOCAL"  ]; then
	wget "https://github.com/KenT2/python-games/tarball/master" -O files/python_games.tar.gz
	echo $HASH > files/python_games.hash
fi

ln -sf pip3 ${ROOTFS_DIR}/usr/bin/pip-3.2

install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/python_games
tar xvf files/python_games.tar.gz -C ${ROOTFS_DIR}/home/pi/python_games --strip-components=1
chown 1000:1000 ${ROOTFS_DIR}/home/pi/python_games -Rv
chmod +x ${ROOTFS_DIR}/home/pi/python_games/launcher.sh

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/Documents"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/Documents/BlueJ Projects"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/Documents/Greenfoot Projects"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/Documents/Scratch Projects"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/applications"

rsync -a --chown=1000:1000 ${ROOTFS_DIR}/usr/share/doc/BlueJ/ "${ROOTFS_DIR}/home/pi/Documents/BlueJ Projects"
rsync -a --chown=1000:1000 ${ROOTFS_DIR}/usr/share/doc/Greenfoot/ "${ROOTFS_DIR}/home/pi/Documents/Greenfoot Projects"
rsync -a --chown=1000:1000 ${ROOTFS_DIR}/usr/share/scratch/Projects/Demos/ "${ROOTFS_DIR}/home/pi/Documents/Scratch Projects"

install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/pcmanfm
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/pcmanfm/LXDE-pi
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/openbox
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/lxsession
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.themes
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/gtk-3.0
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.config/lxpanel
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/Desktop

install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/etc/xdg/pcmanfm/LXDE-pi/pcmanfm.conf ${ROOTFS_DIR}/home/pi/.config/pcmanfm/LXDE-pi/
install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf ${ROOTFS_DIR}/home/pi/.config/pcmanfm/LXDE-pi/

install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/etc/xdg/openbox/lxde-pi-rc.xml ${ROOTFS_DIR}/home/pi/.config/openbox/

rsync -a --chown=1000:1000 ${ROOTFS_DIR}/etc/xdg/lxsession/LXDE-pi ${ROOTFS_DIR}/home/pi/.config/lxsession/
rsync -a --chown=1000:1000 ${ROOTFS_DIR}/usr/share/themes/PiX ${ROOTFS_DIR}/home/pi/.themes/

install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/usr/share/raspi-ui-overrides/gtk.css ${ROOTFS_DIR}/home/pi/.config/gtk-3.0/

install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/usr/share/raspi-ui-overrides/Trolltech.conf ${ROOTFS_DIR}/home/pi/.config/

install -v -m 644 -o 1000 -g 1000 ${ROOTFS_DIR}/etc/xdg/lxpanel/launchtaskbar.cfg ${ROOTFS_DIR}/home/pi/.config/lxpanel/
rsync -a --chown=1000:1000 ${ROOTFS_DIR}/etc/xdg/lxpanel/profile/LXDE-pi ${ROOTFS_DIR}/home/pi/.config/lxpanel/
