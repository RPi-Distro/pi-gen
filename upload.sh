#!/bin/bash

UPDATE_CHANNEL="unstable"

META="$1.meta"
HWID=`jq -r ".update.hwid" $META`
VERSION=`jq -r ".update.version" $META`

echo "Uploading $1 (HWID $HWID/Version $VERSION) to pionix@pionix-update.de/public_html/${HWID}/${UPDATE_CHANNEL}"

#SSHPASS=`cat ~/rauc-pki/sftp-passwd` sshpass -e sftp -oBatchMode=no -b - pionix@pionix-update.de << EOF
sftp -oBatchMode=no -b - pionix@pionix-update.de << EOF
   cd public_html
   -mkdir ${HWID}
   cd ${HWID}
   -mkdir ${UPDATE_CHANNEL}
   cd ${UPDATE_CHANNEL}
   -rm *
   put "$1.pnx"
   put "$1.meta"
   put "$1.meta" "current.meta"
   bye
EOF
