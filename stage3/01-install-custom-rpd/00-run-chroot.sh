#!/bin/bash -e

# Install build dependencies for rpd-metas
apt-get install -y git devscripts debhelper

# Clone the custom rpd-metas repository
cd /tmp
rm -rf rpd-metas
git clone https://github.com/greenpdx/rpd-metas.git
cd rpd-metas
git checkout crmods

# Build the packages
dpkg-buildpackage -b -uc -us

# Install the built packages
cd /tmp
dpkg -i rpd-common_*.deb rpd-wayland-core_*.deb rpd-x-core_*.deb || apt-get install -f -y

# Clean up
rm -rf /tmp/rpd-metas /tmp/rpd-*.deb /tmp/rpd-*.buildinfo /tmp/rpd-*.changes
