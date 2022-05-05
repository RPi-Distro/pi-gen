#!/bin/bash -e

# change hostname to sth unique on first boot
install -m 755 files/update-hostname.sh "${ROOTFS_DIR}/usr/bin"
install -m 644 files/update-hostname.service "${ROOTFS_DIR}/lib/systemd/system/"

# mount root ro after first boot
install -m 755 files/read-only-root.sh "${ROOTFS_DIR}/usr/bin"
install -m 644 files/read-only-root.service "${ROOTFS_DIR}/lib/systemd/system/"

install -m 644 files/user-wpa-supplicant.service "${ROOTFS_DIR}/lib/systemd/system/"

install -m 755 files/ro "${ROOTFS_DIR}/usr/bin"
install -m 755 files/rw "${ROOTFS_DIR}/usr/bin"

install -m 440 files/sudoers "${ROOTFS_DIR}/etc"

# fix VIM mouse support
cp "files/vimrc" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.vimrc"

# prepare for read only root and boot fs
on_chroot <<EOF
apt-get -y remove --purge wolfram-engine triggerhappy anacron logrotate dphys-swapfile xserver-common lightdm
dpkg --purge rsyslog
apt-get -y autoremove --purge
chown ${FIRST_USER_NAME}.users /home/${FIRST_USER_NAME}/.vimrc
systemctl disable console-setup
systemctl disable resize2fs_once.service

rm -rf /var/lib/dhcp /var/lib/dhcpcd5 /var/run /var/spool /var/lock /etc/resolv.conf
ln -s /tmp /var/lib/dhcp
ln -s /tmp /var/lib/dhcpcd5
ln -s /run /var/run
ln -s /tmp /var/spool
ln -s /tmp /var/lock

echo "nameserver 8.8.8.8" > /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf

systemctl enable update-hostname.service

mkdir -p /mnt/user_data
mkdir -p /mnt/factory_data

if [ -L "/etc/ssh" ]; then
    echo Rebuilding over existing work directory, skipping ssh config magic
else
    echo Clean build, symlinking ssh config
    mv /etc/ssh /etc/ssh_factory_defaults
    ln -s /mnt/user_data/etc/ssh /etc/ssh
fi

if [ -L "/etc/wpa_supplicant" ]; then
    echo Rebuilding over existing work directory, skipping wpa_supplicant magic
else
    echo Clean build, symlinking wpa_supplicant
    mkdir -p /etc/wpa_supplicant_factory
    mv /etc/wpa_supplicant/* /etc/wpa_supplicant_factory
    rm -rf /etc/wpa_supplicant
    ln -s /mnt/user_data/etc/wpa_supplicant /etc/wpa_supplicant
fi
systemctl enable user-wpa-supplicant.service

systemctl enable read-only-root.service
EOF

