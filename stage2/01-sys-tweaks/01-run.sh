#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

# enable pi camera
install -m 644 files/picamera.conf	"${ROOTFS_DIR}/etc/modules-load.d/"

# disable wireless
install -m 644 files/raspi-blacklist.conf "${ROOTFS_DIR}/etc/modprobe.d/"

install -m 644 files/frc.json "${ROOTFS_DIR}/boot/"

install -m 755 extfiles/setuidgids "${ROOTFS_DIR}/usr/local/bin/"

cat extfiles/jdk_11.0.1-strip.tar.gz | sh -c "mkdir -p ${ROOTFS_DIR}/usr/lib/jvm && cd ${ROOTFS_DIR}/usr/lib/jvm/ && tar xzf - --exclude=\*.diz --exclude=src.zip --transform=s/^jdk/jdk-11.0.1/"
cp files/jdk-11.0.1.jinfo "${ROOTFS_DIR}/usr/lib/jvm/.jdk-11.0.1.jinfo"

on_chroot << EOF
cd /usr/lib/jvm
grep /usr/lib/jvm .jdk-11.0.1.jinfo | awk '{ print "update-alternatives --install /usr/bin/" \$2 " " \$2 " " \$3 " 2"; }' | bash
update-java-alternatives -s jdk-11.0.1
EOF

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

install -m 644 files/ld.so.conf.d/*.conf "${ROOTFS_DIR}/etc/ld.so.conf.d/"

install -v -d "${ROOTFS_DIR}/usr/local/frc/bin"

install -m 755 extfiles/multiCameraServer "${ROOTFS_DIR}/usr/local/frc/bin/"
install -m 644 extfiles/multiCameraServer.debug "${ROOTFS_DIR}/usr/local/frc/bin/"

cat extfiles/wpilib-bin.tar.gz | sh -c 'cd ${ROOTFS_DIR}/usr/local/frc/bin/ && tar xzf -'

install -v -d "${ROOTFS_DIR}/usr/local/frc/lib"

cat extfiles/libopencv-debug.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/lib/ && tar xzf -"
cat extfiles/libopencv.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/lib/ && tar xzf -"

install -m 755 extfiles/cv2.*.so "${ROOTFS_DIR}/usr/local/lib/python3.5/dist-packages/"

cat extfiles/pynetworktables.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/lib/python3.5/dist-packages/ && tar xzf -"
cat extfiles/robotpy-cscore.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/lib/python3.5/dist-packages/ && tar xzf -"
install -m 755 extfiles/_cscore.*.so "${ROOTFS_DIR}/usr/local/lib/python3.5/dist-packages/cscore/"

cat extfiles/wpilib-debug.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/lib/ && tar xzf -"
cat extfiles/wpilib.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/lib/ && tar xzf -"

install -v -d "${ROOTFS_DIR}/usr/local/frc/include"

cat extfiles/wpiutil-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/cscore-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/ntcore-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/cameraserver-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/hal-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/hal-gen-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/wpilibc-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"
cat extfiles/opencv-include.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/include/ && tar xzf -"

install -v -d "${ROOTFS_DIR}/usr/local/frc/share/OpenCV"

cat extfiles/opencv-cmake-debug.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/share/OpenCV/ && tar xzf -"
cat extfiles/opencv-cmake.tar.gz | sh -c "cd ${ROOTFS_DIR}/usr/local/frc/share/OpenCV/ && tar xzf -"

install -v -d "${ROOTFS_DIR}/usr/local/frc/java"

install -m 644 -o 1000 -g 1000 extfiles/*.jar "${ROOTFS_DIR}/usr/local/frc/java/"

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/examples/"
install -v -o 1000 -g 1000 extfiles/*-multiCameraServer.zip "${ROOTFS_DIR}/home/pi/examples/"
on_chroot << EOF
cd /home/pi/examples/
unzip java-multiCameraServer.zip
unzip cpp-multiCameraServer.zip
unzip python-multiCameraServer.zip
mkdir ../zips
mv *.zip ../zips/
chown -R 1000:1000 .
EOF

# add jar dependencies to java-multiCameraServer.zip
rm -rf /tmp/java-multiCameraServer
mkdir -p /tmp/java-multiCameraServer
sh -c "cd ${ROOTFS_DIR}/usr/local/frc/java && tar cf - *.jar" | sh -c "cd /tmp/java-multiCameraServer && tar xf -"
sh -c "cd /tmp && zip -r ${ROOTFS_DIR}/home/pi/zips/java-multiCameraServer.zip java-multiCameraServer"
rm -rf /tmp/java-multiCameraServer

# add header and library dependencies (excluding .debug files) to
# cpp-multiCameraServer.zip
# also update Makefile to use cross-compiler and point to local dependencies
rm -rf /tmp/cpp-multiCameraServer
mkdir -p /tmp/cpp-multiCameraServer
echo "CXX=arm-raspbian9-linux-gnueabihf-g++" > /tmp/cpp-multiCameraServer/Makefile
sed -e 's/\/usr\/local\/frc\///g' ${ROOTFS_DIR}/home/pi/examples/cpp-multiCameraServer/Makefile >> /tmp/cpp-multiCameraServer/Makefile
sh -c "cd ${ROOTFS_DIR}/usr/local/frc && tar cf - lib include" | sh -c "cd /tmp/cpp-multiCameraServer && tar xf -"
sh -c "cd /tmp && zip -r ${ROOTFS_DIR}/home/pi/zips/cpp-multiCameraServer.zip cpp-multiCameraServer --exclude \*.so.\*"
rm -rf /tmp/cpp-multiCameraServer

on_chroot << EOF
chown -R 1000:1000 /home/pi/zips
ldconfig
EOF

install -v -d "${ROOTFS_DIR}/service/configServer"

install -m 755 files/configServer_run "${ROOTFS_DIR}/service/configServer/run"

install -m 755 extfiles/rpiConfigServer "${ROOTFS_DIR}/usr/local/sbin/configServer"
install -m 644 extfiles/rpiConfigServer.debug "${ROOTFS_DIR}/usr/local/sbin/"

install -v -d "${ROOTFS_DIR}/service/camera"
install -v -d "${ROOTFS_DIR}/service/camera/log"

install -m 755 files/camera_run "${ROOTFS_DIR}/service/camera/run"
install -m 755 files/camera_log_run "${ROOTFS_DIR}/service/camera/log/run"

on_chroot << EOF
cd /service/camera && rm -f supervise && ln -s /tmp/camera-supervise supervise
cd /service/camera/log && rm -f supervise && ln -s /tmp/camera-log-supervise supervise
cd /service/configServer && rm -f supervise && ln -s /tmp/configServer-supervise supervise
cd /etc/service && rm -f camera && ln -s /service/camera .
cd /etc/service && rm -f configServer && ln -s /service/configServer .
EOF

install -m 755 -o 1000 -g 1000 files/runCamera "${ROOTFS_DIR}/home/pi/"
install -m 755 -o 1000 -g 1000 files/runInteractive "${ROOTFS_DIR}/home/pi/"
install -m 755 -o 1000 -g 1000 files/runService "${ROOTFS_DIR}/home/pi/"

rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*
