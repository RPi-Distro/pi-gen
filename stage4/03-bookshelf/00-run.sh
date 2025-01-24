#!/bin/sh -e

BOOKSHELF_URL="https://magpi.raspberrypi.com/bookshelf.xml"
GUIDE_URL="$(curl -s "$BOOKSHELF_URL" | awk -F '[<>]' "/<TITLE>Raspberry Pi Beginner's Guide .*<\/TITLE>/ {f=1; next} f==1 && /PDF/ {print \$3; exit}")"
OUTPUT="$(basename "$GUIDE_URL" | cut -f1 -d'?')"

if [ ! -f "files/$OUTPUT" ]; then
	rm files/*.pdf -f
	curl -s "$GUIDE_URL" -o "files/$OUTPUT"
fi

file "files/$OUTPUT" | grep -q "PDF document"

if [[ "${ENABLE_CLOUD_INIT}" == "0" ]]; then

	install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Bookshelf"
	install -v -o 1000 -g 1000 -m 644 "files/$OUTPUT" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/Bookshelf/"

else

	install -v -o 0 -g 0 -d "/etc/skel/Bookshelf"
	install -v -o 0 -g 0 -m 644 "files/$OUTPUT" "/etc/skel/Bookshelf/"

fi
