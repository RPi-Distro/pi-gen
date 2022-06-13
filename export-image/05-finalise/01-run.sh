#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"
INFO_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.info"

on_chroot << EOF
if [ -x /etc/init.d/fake-hwclock ]; then
	/etc/init.d/fake-hwclock stop
fi
if hash hardlink 2>/dev/null; then
	hardlink -t /usr/share/doc
fi
EOF

if [ -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config" ]; then
	chmod 700 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config"
fi

rm -f "${ROOTFS_DIR}/usr/bin/qemu-arm-static"

if [ "${USE_QEMU}" != "1" ]; then
	if [ -e "${ROOTFS_DIR}/etc/ld.so.preload.disabled" ]; then
		mv "${ROOTFS_DIR}/etc/ld.so.preload.disabled" "${ROOTFS_DIR}/etc/ld.so.preload"
	fi
fi

rm -f "${ROOTFS_DIR}/etc/network/interfaces.dpkg-old"

rm -f "${ROOTFS_DIR}/etc/apt/sources.list~"
rm -f "${ROOTFS_DIR}/etc/apt/trusted.gpg~"

rm -f "${ROOTFS_DIR}/etc/passwd-"
rm -f "${ROOTFS_DIR}/etc/group-"
rm -f "${ROOTFS_DIR}/etc/shadow-"
rm -f "${ROOTFS_DIR}/etc/gshadow-"
rm -f "${ROOTFS_DIR}/etc/subuid-"
rm -f "${ROOTFS_DIR}/etc/subgid-"

rm -f "${ROOTFS_DIR}"/var/cache/debconf/*-old
rm -f "${ROOTFS_DIR}"/var/lib/dpkg/*-old

rm -f "${ROOTFS_DIR}"/usr/share/icons/*/icon-theme.cache

rm -f "${ROOTFS_DIR}/var/lib/dbus/machine-id"

true > "${ROOTFS_DIR}/etc/machine-id"

ln -nsf /proc/mounts "${ROOTFS_DIR}/etc/mtab"

find "${ROOTFS_DIR}/var/log/" -type f -exec cp /dev/null {} \;

rm -f "${ROOTFS_DIR}/root/.vnc/private.key"
rm -f "${ROOTFS_DIR}/etc/vnc/updateid"

update_issue "$(basename "${EXPORT_DIR}")"
install -m 644 "${ROOTFS_DIR}/etc/rpi-issue" "${ROOTFS_DIR}/boot/issue.txt"

cp "$ROOTFS_DIR/etc/rpi-issue" "$INFO_FILE"


{
	if [ -f "$ROOTFS_DIR/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz" ]; then
		firmware=$(zgrep "firmware as of" \
			"$ROOTFS_DIR/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz" | \
			head -n1 | sed  -n 's|.* \([^ ]*\)$|\1|p')
		printf "\nFirmware: https://github.com/raspberrypi/firmware/tree/%s\n" "$firmware"

		kernel="$(curl -s -L "https://github.com/raspberrypi/firmware/raw/$firmware/extra/git_hash")"
		printf "Kernel: https://github.com/raspberrypi/linux/tree/%s\n" "$kernel"

		uname="$(curl -s -L "https://github.com/raspberrypi/firmware/raw/$firmware/extra/uname_string7")"
		printf "Uname string: %s\n" "$uname"
	fi

	printf "\nPackages:\n"
	dpkg -l --root "$ROOTFS_DIR"
} >> "$INFO_FILE"

mkdir -p "${DEPLOY_DIR}"

rm -f "${DEPLOY_DIR}/${ARCHIVE_FILENAME}${IMG_SUFFIX}.*"
rm -f "${DEPLOY_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

mv "$INFO_FILE" "$DEPLOY_DIR/"

if [ "${USE_QCOW2}" = "0" ] && [ "${NO_PRERUN_QCOW2}" = "0" ]; then
	ROOT_DEV="$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')"

	unmount "${ROOTFS_DIR}"
	zerofree "${ROOT_DEV}"

	unmount_image "${IMG_FILE}"
else
	unload_qimage
	make_bootable_image "${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.qcow2" "$IMG_FILE"
fi

case "${DEPLOY_COMPRESSION}" in
zip)
	pushd "${STAGE_WORK_DIR}" > /dev/null
	zip -"${COMPRESSION_LEVEL}" \
	"${DEPLOY_DIR}/${ARCHIVE_FILENAME}${IMG_SUFFIX}.zip" "$(basename "${IMG_FILE}")"
	popd > /dev/null
	;;
gz)
	pigz --force -"${COMPRESSION_LEVEL}" "$IMG_FILE" --stdout > \
	"${DEPLOY_DIR}/${ARCHIVE_FILENAME}${IMG_SUFFIX}.img.gz"
	;;
xz)
	xz --compress --force --threads 0 --memlimit-compress=50% -"${COMPRESSION_LEVEL}" \
	--stdout "$IMG_FILE" > "${DEPLOY_DIR}/${ARCHIVE_FILENAME}${IMG_SUFFIX}.img.xz"
	;;
none | *)
	cp "$IMG_FILE" "$DEPLOY_DIR/"
;;
esac
