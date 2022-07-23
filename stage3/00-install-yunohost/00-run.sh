#!/bin/bash -e

# Prevent dhcp setting the "search" thing in /etc/resolv.conf, leads to many
# weird stuff (e.g. with numericable) where any domain will ping >.>
on_chroot << EOF
echo 'supersede domain-name "";'   >> /etc/dhcp/dhclient.conf
echo 'supersede domain-search "";' >> /etc/dhcp/dhclient.conf
echo 'supersede search "";       ' >> /etc/dhcp/dhclient.conf
EOF

# Disable those damn supposedly "predictive" interface names
# c.f. https://unix.stackexchange.com/a/338730
on_chroot << EOF
rm -f /etc/systemd/network/99-default.link
ln -s /dev/null /etc/systemd/network/99-default.link
EOF

# Enable resize2fs for first boot (without having to log-in ssh)
on_chroot << EOF
systemctl enable resize2fs_once
EOF

# For some reason curl doesnt recognize CA in any cert
# and this is fixed by regerating links in /etc/ssl/certs/ ...
on_chroot << EOF
update-ca-certificates -f -v
EOF

# For some reason curl still doesnt recognize CA in any cert
# and this is fixed by adding a ~/.curlrc file ...
on_chroot << EOF
echo  capath=/etc/ssl/certs/ > /root/.curlrc
echo cacert=/etc/ssl/certs/ca-certificates.crt >> /root/.curlrc
EOF

# Run the actual install
on_chroot << EOF
apt-get install insserv resolvconf -y
curl https://install.yunohost.org/bullseye | bash -s -- -a -d testing
rm -f /etc/ssh/ssh_host_*
EOF

echo "Enabling ssh login for root + setting default password"
on_chroot << EOF
sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
echo "root:yunohost" | chpasswd
EOF

echo "Removing Raspbian sshd banner"
rm /etc/ssh/sshd_config.d/rename_user.conf
rm /usr/share/userconf-pi/sshd_banner

install -m 755 files/check_yunohost_is_installed.sh "${ROOTFS_DIR}/etc/profile.d/"

echo "Cleaning ..."
on_chroot << EOF
apt-get clean
find /var/log -type f -exec rm {} \;
EOF


# Gotta manually kill those stuff which are some sort of daemon running
# for slapd / nscd / nslcd ... otherwise the script is unable to unmount
# the rootfs/image after that ?
while lsof 2>/dev/null | grep -q /root/rpi-image/work/*/export-image/rootfs/dev;
do
    for PID in `ps -ef --forest | grep "qemu-binfmt" | grep -v "grep" | grep "nginx\|nscd\|slapd\|nslcd" | awk '{print $2}'`
    do
        echo "Killing $PID"
        kill -9 $PID || true
        sleep 1
    done
    sleep 5
done
while ps -ef --forest | grep "qemu-binfmt" | grep -v "grep"
do
    for PID in `ps -ef --forest | grep "qemu-binfmt" | grep -v "grep" | grep "nginx\|nscd\|slapd\|nslcd" | awk '{print $2}'`
    do
        echo "Killing $PID"
        kill -9 $PID || true
        sleep 1
    done
    sleep 5
done
