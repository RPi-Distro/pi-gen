#!/bin/bash -e

# Install build dependencies for piwiz
apt-get install -y git devscripts debhelper

# Clone the custom piwiz repository
cd /tmp
rm -rf piwiz
git clone https://github.com/preenpdx/piwiz.git
cd piwiz
git checkout crmods

# Build the package
dpkg-buildpackage -b -uc -us

# Install the built package
cd /tmp
dpkg -i piwiz_*.deb || apt-get install -f -y

# Clean up
rm -rf /tmp/piwiz /tmp/piwiz_*.deb /tmp/piwiz_*.buildinfo /tmp/piwiz_*.changes
