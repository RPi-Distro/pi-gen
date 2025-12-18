#!/usr/bin/env bash
set -euo pipefail

install -m 644 files/openwebrx.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/openwebrx-plus.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

gpg --dearmor < files/openwebrx.gpg.key > "${ROOTFS_DIR}/usr/share/keyrings/openwebrx.gpg"
gpg --dearmor < files/openwebrx-plus.gpg.key > "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/openwebrx-plus.gpg"

on_chroot << EOF

repo_lines=(
    'deb [ arch=armhf ] http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware'
    'deb [ arch=armhf ] http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware'
    'deb [ arch=armhf ] http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware'
)

# Remove existing entries to avoid duplicates
for repo_line in "\${repo_lines[@]}"; do
    perl -0pi -e 's{^\Q'"\$repo_line"'\E\n?}{}mg' /etc/apt/sources.list
done

# Add the repository lines
for repo_line in "\${repo_lines[@]}"; do
    echo "\$repo_line" >> /etc/apt/sources.list
done

apt update --allow-unauthenticated || true

# fix previous broken installs (if any)
apt remove --purge -y soapysdr-module-sdrplay3 soapysdr0.8-module-sdrplay3 || true
apt --fix-broken install || true

apt install gnupg
gpg --batch --yes --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8
gpg --batch --yes --pinentry-mode=loopback --export 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8 | gpg --batch --yes --dearmor -o /etc/apt/trusted.gpg.d/debian-archive.gpg
apt update
apt install debian-archive-keyring --reinstall

echo ------------------------------------------
cat /etc/apt/sources.list
echo ------------------------------------------

EOF
