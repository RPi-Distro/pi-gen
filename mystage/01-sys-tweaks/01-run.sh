#!/bin/bash -e
# https://sites.ualberta.ca/dept/chemeng/AIX-43/share/man/info/C/a_doc_lib/cmds/aixcmds3/install.htm
# https://sourcedigit.com/23234-apt-get-install-specific-version-of-package-ubuntu-apt-get-list/
# https://unix.stackexchange.com/questions/159094/how-to-install-a-deb-file-by-dpkg-i-or-by-apt

files/lazycast -type f -exec install -Dm 644 "{}" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/{}"

install -m 644 /files/wpasupplicant_2.4-1+deb9u6_armhf.deb "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"