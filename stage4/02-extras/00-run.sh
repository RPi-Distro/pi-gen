#!/bin/bash -e

HASH="$(wget https://api.github.com/repos/KenT2/python-games/git/refs/heads/master -qO -| grep \"sha\" | cut -f 2 -d ':' | cut -f 2 -d \")"

if [ -f files/python_games.hash ]; then
	HASH_LOCAL="$(cat files/python_games.hash)"
fi

if [ ! -e files/python_games.tar.gz ] || [ "$HASH" != "$HASH_LOCAL"  ]; then
	wget "https://github.com/KenT2/python-games/tarball/master" -O files/python_games.tar.gz
	echo "$HASH" > files/python_games.hash
fi

ln -sf pip3 "${ROOTFS_DIR}/usr/bin/pip-3.2"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/python_games"
tar xvf files/python_games.tar.gz -C "${ROOTFS_DIR}/home/pi/python_games" --strip-components=1
chown 1000:1000 "${ROOTFS_DIR}/home/pi/python_games" -Rv
chmod +x "${ROOTFS_DIR}/home/pi/python_games/launcher.sh"

#Alacarte fixes
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/applications"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/desktop-directories"
