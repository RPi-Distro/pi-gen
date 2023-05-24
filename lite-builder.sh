#!/bin/bash
rm config
printf "IMG_NAME="mqpi"\nFIRST_USER_NAME="pi"\nFIRST_USER_PASS="mqpi"\nDISABLE_FIRST_BOOT_USER_RENAME=1\nENABLE_SSH=1\nSTAGE_LIST=\"stage0 stage1 stage2 mqstage\"" > config
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES
touch ./mqstage/EXPORT_IMAGE
sudo ./build.sh -c config