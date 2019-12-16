#!/bin/bash -e

set -x

if [[ $(find /pi-gen/dist -maxdepth 1 -name '*.deb' -print -quit) ]]
then
  echo "--- Using Buildkite-provided Kolibri deb"

  # All files copied at build stage to /pi-gen
  mv /pi-gen/dist/*.deb $ROOTFS_DIR

  on_chroot << EOF
  dpkg -i /*.deb
EOF

  echo "--- Continuing Image Build "
fi

install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/KOLIBRI_DATA/content"
install -m 644 -o 1000 -g 1000  options.ini "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.kolibri/"
