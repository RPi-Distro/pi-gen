#!/bin/bash -e

# Install build dependencies for piwiz
apt-get install -y git devscripts debhelper \
    libgtk-3-dev intltool libpackagekit-glib2-dev dh-exec \
    libsecret-1-dev libnm-dev libnma-dev

# Disable git credential prompts (prevent build from hanging)
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/true

# Clone the custom piwiz repository
cd /tmp
rm -rf piwiz
git clone --depth 1 --branch crmods https://github.com/greenpdx/piwiz.git
cd piwiz

# Build the package
dpkg-buildpackage -b -uc -us

# Install the built package
cd /tmp
dpkg -i piwiz_*.deb || apt-get install -f -y

# Clean up build dependencies
apt-get purge -y git devscripts debhelper \
    libgtk-3-dev intltool libpackagekit-glib2-dev dh-exec \
    libsecret-1-dev libnm-dev libnma-dev
apt-get autoremove -y
apt-get clean

# Clean up temporary files
rm -rf /tmp/piwiz /tmp/piwiz_*.deb /tmp/piwiz_*.buildinfo /tmp/piwiz_*.changes
