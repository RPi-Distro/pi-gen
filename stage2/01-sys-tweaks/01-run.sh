#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
if [ "${ENABLE_SSH}" == "1" ]; then
	systemctl enable ssh
else
	systemctl disable ssh
fi
systemctl enable regenerate_ssh_host_keys
EOF

if [ "${USE_QEMU}" = "1" ]; then
	echo "enter QEMU mode"
	install -m 644 files/90-qemu.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
	on_chroot << EOF
systemctl disable resize2fs_once
EOF
	echo "leaving QEMU mode"
else
	on_chroot << EOF
systemctl enable resize2fs_once
EOF
fi

on_chroot <<EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r "\$GRP"
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

on_chroot << EOF
usermod --pass='*' root
EOF

# Add Step to get certificates from LAN
# Update /lib/systemd/system/docker.service
# Add Certificates for docker host
# Get .ssh/authorized_keys for help on login 
# Update node name based on mac
# https://stackoverflow.com/questions/11735409/how-do-i-set-curl-to-always-use-the-k-option

cp ../../on-boot/preparePi.sh ${ROOTFS_DIR}/home/pi/
cp $HOME/manager.host ${ROOTFS_DIR}/home/pi/
on_chroot <<EOF
chmod +x /home/pi/preparePi.sh
apt-get install -y apt-transport-https ca-certificates software-properties-common
update-ca-certificates --fresh
echo insecure >> $HOME/.curlrc
curl -O https://curl.haxx.se/ca/cacert.pem > /etc/ssl/certs/cacert.pem
curl -sSL   https://get.docker.com/ | sh
usermod -aG docker pi
systemctl enable docker.service
rm -f $HOME/.curlrc
cat /home/pi/manager.host  >> /etc/hosts
cp /etc/rc.local /home/pi/rc.local
cat /home/pi/rc.local | grep -v "exit 0" > /etc/rc.local
echo "/home/pi/preparePi.sh" >> /home/pi/rc.local
echo "exit 0" >> /home/pi/rc.local
EOF
rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*
