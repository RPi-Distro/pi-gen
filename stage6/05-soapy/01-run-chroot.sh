#!/usr/bin/env bash
set -euo pipefail

# mark soapy modules as manualy installed, so the autoremove will not remove unused
apt-mark manual $(apt-cache depends soapysdr0.8-module-all | grep "Depends: " | cut -d':' -f2)


