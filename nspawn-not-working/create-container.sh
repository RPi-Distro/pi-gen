#!/bin/bash

echo "--- bootstraping debian bookworm..."
if [ -d debian-containers/bookworm ]; then
	echo already built.
else
	mkdir -p debian-containers
	pushd debian-containers
	sudo debootstrap --include=dbus-broker,systemd-container --components=main,universe bookworm bookworm  https://deb.debian.org/debian/
	popd
fi


sudo systemd-nspawn --pipe -q -U -D ./debian-containers/bookworm/ << __EOF__
echo '--- setting root password to " " (space character)...'
echo "root: " | chpasswd

echo '=== updating system...'
apt update
apt upgrade -y

echo '=== installing packages...'
apt install -y quilt parted debootstrap zerofree zip dosfstools libarchive-tools rsync xz-utils curl xxd file git bc gpg pigz qemu-user-static vim

echo '=== enabling autologin...'
export ALDIR="/etc/systemd/system/console-getty.service.d/"
mkdir -p \$ALDIR
echo "[Service]" > \$ALDIR/override.conf
echo "ExecStart=" >> \$ALDIR/override.conf
#echo "ExecStart=-/sbin/agetty --noclear --autologin root %I \\\$TERM" >> \$ALDIR/override.conf
echo "ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --keep-baud --autologin root - 115200,38400,9600 \\\$TERM" >> \$ALDIR/override.conf

echo '=== enabling binfmt'
echo 'none /proc/sys/fs/binfmt_misc binfmt_misc defaults 0 0' >> /etc/fstab

cp -a /etc/skel/.* ~/
echo 'set bg=dark' > /etc/vim/vimrc.local
echo 'set modeline' >> /etc/vim/vimrc.local
__EOF__



