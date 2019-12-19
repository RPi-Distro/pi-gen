#!/bin/bash -e

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
