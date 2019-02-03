#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

#
# Install OpenJDK
#
pushd "${STAGE_WORK_DIR}"
wget -nc -nv \
    https://github.com/wpilibsuite/raspbian-openjdk/releases/download/v2019-11.0.1-1/jdk_11.0.1-strip.tar.gz
popd

mkdir -p "${ROOTFS_DIR}/usr/lib/jvm"
pushd "${ROOTFS_DIR}/usr/lib/jvm"
tar xzf "${STAGE_WORK_DIR}/jdk_11.0.1-strip.tar.gz" \
    --exclude=\*.diz \
    --exclude=src.zip \
    --transform=s/^jdk/jdk-11.0.1/
popd
cp files/jdk-11.0.1.jinfo "${ROOTFS_DIR}/usr/lib/jvm/.jdk-11.0.1.jinfo"
install -m 644 files/ld.so.conf.d/*.conf "${ROOTFS_DIR}/etc/ld.so.conf.d/"

on_chroot << EOF
cd /usr/lib/jvm
grep /usr/lib/jvm .jdk-11.0.1.jinfo | awk '{ print "update-alternatives --install /usr/bin/" \$2 " " \$2 " " \$3 " 2"; }' | bash
update-java-alternatives -s jdk-11.0.1
ldconfig
EOF

#
# Set up for read-only file system
#
on_chroot << EOF
rm -rf /var/lib/dhcp/ /var/run /var/spool /var/lock
ln -s /tmp /var/lib/dhcp
ln -s /run /var/run
ln -s /tmp /var/spool
ln -s /tmp /var/lock
sed -i -e 's/d \/var\/spool/#d \/var\/spool/' /usr/lib/tmpfiles.d/var.conf
sed -i -e 's/\/var\/lib\/ntp/\/var\/tmp/' /etc/ntp.conf
EOF

cat files/bash.bashrc >> "${ROOTFS_DIR}/etc/bash.bashrc"

cat files/bash.logout >> "${ROOTFS_DIR}/etc/bash.bash_logout"

on_chroot << EOF
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

rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*
