#!/bin/bash -e

RAUC_DIR="${STAGE_WORK_DIR}/${IMG_NAME}${IMG_SUFFIX}"

install -v		files/manifest.raucm		"${RAUC_DIR}/"
# replace version number in manifest
sed -i "s/VERSION/${IMG_FILENAME}/g" "${RAUC_DIR}/manifest.raucm"

rm -f "${DEPLOY_DIR}/${IMG_FILENAME}.raucb"
rauc --cert ~/rauc-pki/pionix-rauc-update.cert.pem --key ~/rauc-pki/pionix-rauc-update.key.pem bundle "${RAUC_DIR}" "${DEPLOY_DIR}/${IMG_FILENAME}.raucb"
mv "${DEPLOY_DIR}/${IMG_FILENAME}.raucb" "${DEPLOY_DIR}/${IMG_FILENAME}.pnx"

