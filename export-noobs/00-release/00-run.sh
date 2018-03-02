#!/bin/bash -e

NOOBS_DIR="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}"

install -v -m 744	files/partition_setup.sh	"${NOOBS_DIR}/"
install -v		files/partitions.json		"${NOOBS_DIR}/"
install -v		files/os.json			"${NOOBS_DIR}/"
install -v		files/OS.png			"${NOOBS_DIR}/"
install -v		files/release_notes.txt		"${NOOBS_DIR}/"

tar -v -c -C		files/marketing			-f "${NOOBS_DIR}/marketing.tar" .

BOOT_SIZE="$(xz --robot -l "${NOOBS_DIR}/boot.tar.xz"  | grep totals | cut -f 5)"
ROOT_SIZE="$(xz --robot -l "${NOOBS_DIR}/root.tar.xz"  | grep totals | cut -f 5)"

BOOT_SIZE="$(( BOOT_SIZE / 1000000 + 1))"
ROOT_SIZE="$(( ROOT_SIZE / 1000000 + 1))"

BOOT_NOM="$(( BOOT_SIZE * 3 ))"
ROOT_NOM="$(( ROOT_SIZE + 400 ))"

mv "${NOOBS_DIR}/OS.png" "${NOOBS_DIR}/${NOOBS_NAME// /_}.png"

sed "${NOOBS_DIR}/partitions.json" -i -e "s|BOOT_SIZE|${BOOT_SIZE}|"
sed "${NOOBS_DIR}/partitions.json" -i -e "s|ROOT_SIZE|${ROOT_SIZE}|"

sed "${NOOBS_DIR}/partitions.json" -i -e "s|BOOT_NOM|${BOOT_NOM}|"
sed "${NOOBS_DIR}/partitions.json" -i -e "s|ROOT_NOM|${ROOT_NOM}|"

sed "${NOOBS_DIR}/os.json" -i -e "s|UNRELEASED|${IMG_DATE}|"
sed "${NOOBS_DIR}/os.json" -i -e "s|NOOBS_NAME|${NOOBS_NAME}|"
sed "${NOOBS_DIR}/os.json" -i -e "s|NOOBS_DESCRIPTION|${NOOBS_DESCRIPTION}|"

sed "${NOOBS_DIR}/release_notes.txt" -i -e "s|UNRELEASED|${IMG_DATE}|"

cp -a "${NOOBS_DIR}" "${DEPLOY_DIR}/"
