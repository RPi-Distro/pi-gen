#!/bin/bash -e

mkdir "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts"
install -m 700 files/get-config-script "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/"
install -m 644 files/farm-environment "${ROOTFS_DIR}/etc/"
install -m 644 files/hostname-gen.service "${ROOTFS_DIR}/etc/systemd/system/"

chown 1000:1000 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/get-config-script"
chown 1000:1000 "${ROOTFS_DIR}/etc/farm-environment"

sed -i 's:CONF_SWAPSIZE=.*:CONF_SWAPSIZE=2048:g' "${ROOTFS_DIR}/etc/dphys-swapfile"

ln -sv "/etc/systemd/system/hostname-gen.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/hostname-gen.service"
ln -sv "/usr/lib/systemd/system/vncserver-x11-serviced.service" "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/vncserver-x11-serviced.service"

rm -rf global-vpn
mkdir global-vpn
curl http://cdn.get.legato/tools/testbench/vpn/global/latest/global-vpn.tgz -o "global-vpn/global-vpn.tgz"
tar zxvf global-vpn/global-vpn.tgz --directory "global-vpn"
deb_file=$(ls global-vpn/GlobalProtect_deb_arm*.deb)
install -m 644 $deb_file "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/scripts/$(basename $deb_file)"

on_chroot << EOF
sudo bash -c "yes | dpkg -i /home/${FIRST_USER_NAME}/scripts/$(basename $deb_file)"
EOF

tee "${ROOTFS_DIR}/opt/paloaltonetworks/globalprotect/pangps.xml" <<CONFIG
<?xml version="1.0" encoding="UTF-8"?>
<GlobalProtect>
  <Settings>
    <disable-globalprotect>0</disable-globalprotect>
    <default-browser>yes</default-browser>
  </Settings>
  <PanSetup>
    <InstallHistory>Fresh Install</InstallHistory>
    <CurrentVersion>6.0.1-6</CurrentVersion>
    <PreviousVersion/>
  </PanSetup>
  <PanGPS>
    <UserProfileType>0</UserProfileType>
    <disable-globalprotect>0</disable-globalprotect>
  </PanGPS>
</GlobalProtect>
CONFIG
