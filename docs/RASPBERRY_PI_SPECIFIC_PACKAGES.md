# Raspberry Pi-Specific Packages Documentation

This document lists every package that adds support **specifically and exclusively for Raspberry Pi hardware**. These packages would not function or are not needed on generic ARM64 or x86 systems.

---

## 🔴 CRITICAL: Hardware-Specific Packages (Cannot be replaced)

These packages are essential for Raspberry Pi hardware to function and have no generic alternatives.

### Firmware & Bootloader (Stage 0)

#### `raspi-firmware`
- **Stage**: stage0/02-firmware
- **Purpose**: Raspberry Pi GPU firmware and bootloader files
- **Location**: `/boot/firmware/`
- **Hardware Dependency**: Required for Raspberry Pi boot process
- **Can Replace?**: ❌ NO - Essential for Pi to boot
- **Alternative**: None - Pi-specific bootloader
- **Impact if Removed**: System will not boot

#### `linux-image-rpi-v8`
- **Stage**: stage0/02-firmware
- **Purpose**: Linux kernel optimized for Raspberry Pi 64-bit (BCM2711/BCM2837)
- **Architecture**: ARM64 for Pi 3/4/Zero 2
- **Can Replace?**: ⚠️ MAYBE - Could use generic arm64 kernel but lose optimizations
- **Alternative**: `linux-image-arm64` (generic, less optimized)
- **Impact if Removed**: No boot on Pi 3/4/Zero 2

#### `linux-image-rpi-2712`
- **Stage**: stage0/02-firmware
- **Purpose**: Linux kernel optimized for Raspberry Pi 5 (BCM2712 SoC)
- **Architecture**: ARM64 for Pi 5
- **Can Replace?**: ⚠️ MAYBE - Could use generic arm64 kernel but lose Pi 5 features
- **Alternative**: `linux-image-arm64` (generic, less optimized)
- **Impact if Removed**: No boot on Pi 5

#### `linux-headers-rpi-v8`
- **Stage**: stage0/02-firmware
- **Purpose**: Kernel headers for building modules for rpi-v8 kernel
- **Can Replace?**: Only if not compiling kernel modules
- **Impact if Removed**: Cannot compile kernel modules

#### `linux-headers-rpi-2712`
- **Stage**: stage0/02-firmware
- **Purpose**: Kernel headers for building modules for Pi 5 kernel
- **Can Replace?**: Only if not compiling kernel modules
- **Impact if Removed**: Cannot compile kernel modules for Pi 5

### Package Repository Access (Stage 0)

#### `raspberrypi-archive-keyring`
- **Stage**: stage0/00-configure-apt
- **Purpose**: GPG keys for authenticating Raspberry Pi Debian repository
- **Repository**: http://archive.raspberrypi.com/debian/
- **Can Replace?**: ❌ NO - Required to install any Pi-specific packages
- **Impact if Removed**: Cannot install any packages from Raspberry Pi repos

---

## 🟠 HARDWARE SUPPORT: System Modifications & Hardware Control

These packages provide Raspberry Pi-specific system tweaks and hardware management.

### System Modifications (Stage 1 & 2)

#### `raspi-config`
- **Stage**: stage1/01-sys-tweaks
- **Purpose**: Configuration tool for Raspberry Pi-specific settings
- **Features**:
  - Overclocking
  - Camera/SPI/I2C/GPIO enable/disable
  - Video memory split
  - Boot behavior
  - Display settings (composite, HDMI, etc.)
  - Serial port configuration
  - Audio output selection
- **Can Replace?**: ✅ YES - Manual config file editing
- **Alternative**: Edit `/boot/firmware/config.txt` manually
- **Impact if Removed**: No GUI/TUI for hardware configuration

#### `raspberrypi-sys-mods`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi-specific system modifications
- **Features**:
  - udev rules for Pi hardware
  - System service modifications
  - Hardware-specific configurations
  - rfkill settings for wireless
  - Swap file management
  - initramfs customizations
- **Can Replace?**: ⚠️ PARTIAL - Must manually replicate needed features
- **Impact if Removed**: Missing hardware-specific system tweaks

#### `raspberrypi-net-mods`
- **Stage**: stage2/02-net-tweaks
- **Purpose**: Raspberry Pi-specific network modifications
- **Features**:
  - Network interface naming
  - WiFi country code settings
  - Bluetooth configurations
- **Can Replace?**: ⚠️ PARTIAL - Manual network configuration
- **Impact if Removed**: May need manual network setup

#### `raspi-utils`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi utility commands
- **Commands**: Tools for Pi-specific operations
- **Can Replace?**: ✅ YES - If not using the utilities
- **Impact if Removed**: Lose Pi-specific command-line utilities

---

## 🟡 HARDWARE INTERFACES: GPIO, Camera, USB

Packages for interfacing with Raspberry Pi hardware peripherals.

### GPIO & Hardware Access (Stage 2)

#### `python3-rpi-lgpio`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Python library for Raspberry Pi GPIO using lgpio backend
- **Hardware**: Accesses Pi GPIO pins
- **Can Replace?**: ❌ NO - Pi-specific GPIO hardware
- **Alternative**: `python3-libgpiod` (generic Linux GPIO, limited Pi support)
- **Impact if Removed**: Cannot control GPIO from Python

#### `python3-gpiozero`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: High-level Python GPIO library for Raspberry Pi
- **Hardware**: Built on top of rpi-lgpio or RPi.GPIO
- **Can Replace?**: ⚠️ MAYBE - Works on some other SBCs with compatible backends
- **Impact if Removed**: Lose easy GPIO programming interface

#### `gpiod python3-libgpiod`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Generic Linux GPIO library (not Pi-specific)
- **Pi-Specific?**: ❌ NO - Generic Linux tool
- **Note**: Works on Raspberry Pi but also any Linux system with GPIO

#### `python3-spidev`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Python SPI bus access
- **Pi-Specific?**: ❌ NO - Generic Linux SPI interface
- **Works on Pi**: Yes, but not Pi-exclusive

#### `python3-smbus2`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Python I2C/SMBus library
- **Pi-Specific?**: ❌ NO - Generic Linux I2C interface
- **Works on Pi**: Yes, but not Pi-exclusive

### Camera Support (Stage 2)

#### `rpicam-apps-lite`
- **Stage**: stage2/01-sys-tweaks-nr (no recommends)
- **Purpose**: Raspberry Pi camera applications (libcamera-based)
- **Hardware**: Raspberry Pi Camera Module (all versions)
- **Replaces**: Legacy raspistill/raspivid commands
- **Can Replace?**: ⚠️ PARTIAL - Generic libcamera apps exist but less optimized
- **Alternative**: Generic `libcamera-apps` package
- **Impact if Removed**: Cannot use Pi Camera modules optimally

### USB & Keyboard (Stage 2)

#### `rpi-usb-gadget`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi USB gadget mode configuration
- **Hardware**: Pi Zero/Zero 2/4 Compute Module USB OTG port
- **Features**: Configure Pi to act as USB device (keyboard, network, storage)
- **Can Replace?**: ❌ NO - Pi-specific USB OTG configuration
- **Impact if Removed**: Cannot use USB gadget mode

#### `rpi-keyboard-config`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Configuration for official Raspberry Pi Keyboard
- **Hardware**: Raspberry Pi Official Keyboard
- **Can Replace?**: ✅ YES - Only needed for official Pi keyboard
- **Impact if Removed**: Official Pi keyboard loses special functions

#### `rpi-keyboard-fw-update`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Firmware updater for official Raspberry Pi Keyboard
- **Hardware**: Raspberry Pi Official Keyboard
- **Can Replace?**: ✅ YES - Only needed for official Pi keyboard
- **Impact if Removed**: Cannot update Pi keyboard firmware

---

## 🟢 MAINTENANCE & UPDATES

Packages for updating Raspberry Pi firmware and system components.

#### `rpi-update`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Tool to update Raspberry Pi firmware to latest (bleeding edge)
- **Warning**: Can install unstable firmware
- **Can Replace?**: ✅ YES - Use apt for stable updates instead
- **Alternative**: Regular `apt update && apt upgrade`
- **Impact if Removed**: Cannot install experimental firmware

#### `rpi-eeprom`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi 4/5 bootloader EEPROM firmware and updater
- **Hardware**: Raspberry Pi 4, Pi 400, Pi 5, Compute Module 4
- **Critical**: Required for Pi 4/5 bootloader updates
- **Can Replace?**: ❌ NO - Pi 4/5 need EEPROM updates for bug fixes
- **Impact if Removed**: Cannot update Pi 4/5 bootloader, potential boot issues

---

## 🔵 CONNECTIVITY & REMOTE ACCESS

#### `rpi-connect-lite`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi Connect remote access service
- **Service**: Cloud-based remote desktop/shell access (connect.raspberrypi.com)
- **Pi-Specific?**: ✅ YES - Raspberry Pi service
- **Can Replace?**: ✅ YES - Use VNC, SSH, or other remote access
- **Alternative**: VNC server, SSH, TeamViewer, etc.
- **Impact if Removed**: Cannot use Raspberry Pi Connect service

---

## 🟣 STORAGE & SWAP

#### `rpi-swap`
- **Stage**: stage2/01-sys-tweaks
- **Purpose**: Raspberry Pi swap file management
- **Features**: Dynamic swap file sizing for SD cards
- **Can Replace?**: ✅ YES - Use generic `dphys-swapfile` or manual swap
- **Alternative**: `dphys-swapfile` or manual swap configuration
- **Impact if Removed**: No automatic swap management

#### `rpi-loop-utils`
- **Stage**: stage2/01-sys-tweaks (same line as rpi-swap)
- **Purpose**: Loop device utilities for Raspberry Pi
- **Can Replace?**: ✅ YES - Generic loop device tools exist
- **Impact if Removed**: May lose some Pi-specific loop device features

---

## 🎨 DESKTOP ENVIRONMENT: Raspberry Pi Desktop (rpd-*)

All packages starting with `rpd-` are **Raspberry Pi Desktop specific** and contain branding, themes, and configurations.

### Core Desktop Packages (Stage 3)

#### `rpd-preferences`
- **Stage**: stage3/00-install-packages
- **Purpose**: Default preferences and settings for Raspberry Pi Desktop
- **Contains**: Default configs, wallpapers, desktop settings
- **Branding**: ✅ YES - Raspberry Pi branded
- **Can Replace?**: ✅ YES - Use generic desktop preferences
- **Impact if Removed**: Lose Pi desktop defaults

#### `rpd-theme`
- **Stage**: stage3/00-install-packages
- **Purpose**: Raspberry Pi Desktop visual theme
- **Contains**: GTK theme, icons, wallpapers, window decorations
- **Branding**: ✅ YES - Heavy Raspberry Pi branding
- **Can Replace?**: ✅ YES - Use any GTK theme
- **Alternative**: Adwaita, Arc, Numix, etc.
- **Impact if Removed**: Generic desktop appearance

#### `rpd-wayland-core`
- **Stage**: stage3/00-install-packages-nr (no recommends)
- **Purpose**: Core Wayland compositor setup for Raspberry Pi Desktop
- **Contains**: Labwc compositor configuration for Pi
- **Can Replace?**: ⚠️ PARTIAL - Generic Wayland compositors exist
- **Alternative**: Generic labwc, sway, wayfire
- **Impact if Removed**: No Pi-optimized Wayland setup

#### `rpd-x-core`
- **Stage**: stage3/00-install-packages-nr (no recommends)
- **Purpose**: Core X11 window manager setup for Raspberry Pi Desktop
- **Contains**: Openbox configuration for Pi (older hardware)
- **Can Replace?**: ✅ YES - Use generic X11 window managers
- **Alternative**: Generic openbox, i3, fluxbox
- **Impact if Removed**: No Pi-optimized X11 setup

### Desktop Application Metapackages (Stage 4)

#### `rpd-applications`
- **Stage**: stage4/00-install-packages
- **Purpose**: Metapackage for Raspberry Pi Desktop applications
- **Contains**: Pulls in recommended applications
- **Can Replace?**: ✅ YES - Install applications individually
- **Impact if Removed**: No curated app selection

#### `rpd-developer`
- **Stage**: stage4/00-install-packages
- **Purpose**: Metapackage for development tools
- **Contains**: Programming tools, IDEs
- **Can Replace?**: ✅ YES - Install dev tools individually
- **Impact if Removed**: Must install dev tools manually

#### `rpd-graphics`
- **Stage**: stage4/00-install-packages
- **Purpose**: Metapackage for graphics applications
- **Contains**: GIMP, Inkscape, etc.
- **Can Replace?**: ✅ YES - Install graphics apps individually
- **Impact if Removed**: Must install graphics apps manually

#### `rpd-utilities`
- **Stage**: stage4/00-install-packages
- **Purpose**: Metapackage for system utilities
- **Contains**: File managers, system tools
- **Can Replace?**: ✅ YES - Install utilities individually
- **Impact if Removed**: Must install utilities manually

#### `rpd-wayland-extras`
- **Stage**: stage4/00-install-packages
- **Purpose**: Extra Wayland components for Raspberry Pi Desktop
- **Can Replace?**: ✅ YES - Use generic Wayland tools
- **Impact if Removed**: Missing some Wayland desktop features

#### `rpd-x-extras`
- **Stage**: stage4/00-install-packages
- **Purpose**: Extra X11 components for Raspberry Pi Desktop
- **Can Replace?**: ✅ YES - Use generic X11 tools
- **Impact if Removed**: Missing some X11 desktop features

---

## 📦 RASPBERRY PI-OPTIMIZED APPLICATIONS

### LibreOffice (Stage 5)

#### `libreoffice-pi`
- **Stage**: stage5/00-install-libreoffice
- **Purpose**: Raspberry Pi-optimized version of LibreOffice
- **Optimization**: Better performance on Pi hardware
- **Can Replace?**: ✅ YES - Use regular `libreoffice` package
- **Alternative**: `libreoffice` (standard Debian package)
- **Impact if Removed**: Slower LibreOffice performance on Pi

### Educational Software (Stage 5)

#### `scratch3`
- **Stage**: stage5/00-install-extras
- **Purpose**: Visual programming for education
- **Pi-Specific?**: ⚠️ PARTIAL - Pi version includes GPIO blocks
- **Can Replace?**: ✅ YES - Use web version or generic build
- **Alternative**: Online Scratch editor
- **Impact if Removed**: No offline Scratch with GPIO support

#### `code-the-classics` & `code-the-classics-2`
- **Stage**: stage5/00-install-extras
- **Purpose**: Raspberry Pi Press educational games with source code
- **Pi-Specific?**: ✅ YES - Raspberry Pi Foundation publications
- **Can Replace?**: ✅ YES - Optional educational content
- **Impact if Removed**: Missing educational game examples

---

## 📊 SUMMARY STATISTICS

### Total Package Count by Category

| Category | Package Count | Pi-Exclusive |
|----------|--------------|--------------|
| **Firmware & Bootloader** | 6 | 🔴 Critical |
| **System Modifications** | 4 | 🟠 Important |
| **GPIO & Hardware** | 6 | 🟡 Hardware-dependent |
| **Maintenance & Updates** | 2 | 🟢 Optional |
| **Connectivity** | 1 | 🔵 Optional |
| **Storage** | 2 | 🟢 Optional |
| **Desktop (rpd-*)** | 10 | 🎨 Optional |
| **Optimized Apps** | 4 | 📦 Optional |
| **TOTAL** | 35 | - |

### Packages by Replaceability

| Can Replace? | Count | Examples |
|--------------|-------|----------|
| ❌ Cannot Replace (Critical) | 8 | raspi-firmware, linux-image-rpi-*, raspberrypi-archive-keyring, rpi-eeprom |
| ⚠️ Partial Replacement | 6 | raspberrypi-sys-mods, rpicam-apps-lite, rpd-wayland-core |
| ✅ Fully Replaceable | 21 | All rpd-* packages, rpi-connect-lite, scratch3, libreoffice-pi |

---

## 🎯 RECOMMENDATIONS FOR CUSTOM BUILD

### If Building for Raspberry Pi Hardware:
**KEEP** (Essential):
- raspi-firmware
- linux-image-rpi-*
- linux-headers-rpi-* (if compiling modules)
- raspberrypi-archive-keyring
- rpi-eeprom (for Pi 4/5)

**KEEP** (Highly Recommended):
- raspberrypi-sys-mods
- raspberrypi-net-mods
- raspi-config (or manually configure)
- python3-rpi-lgpio (if using GPIO)

**REMOVE** (Safe to remove for custom branding):
- All `rpd-*` packages (replace with your own desktop theme)
- rpi-connect-lite (if not using Pi Connect service)
- scratch3, code-the-classics (educational content)
- libreoffice-pi (use standard libreoffice)

**REMOVE** (If not needed):
- rpi-update (use apt instead)
- rpi-keyboard-* (unless using official Pi keyboard)
- rpi-usb-gadget (unless using USB gadget mode)
- rpicam-apps-lite (if not using Pi Camera)

### If Building for Non-Pi ARM64 Hardware:
**REMOVE ALL** Pi-specific packages and use generic equivalents:
- Replace `linux-image-rpi-*` with `linux-image-arm64`
- Remove all `raspberrypi-*`, `rpi-*`, `raspi-*` packages
- Remove all `rpd-*` packages
- Use generic desktop environment (LXDE, XFCE, GNOME, etc.)
- Use generic GPIO libraries if hardware supports it

---

## 📝 NOTES

1. **Firmware Dependencies**: The Pi cannot boot without `raspi-firmware` and `linux-image-rpi-*` packages. These are non-negotiable for Raspberry Pi hardware.

2. **GPIO Access**: If your use case involves GPIO programming on Raspberry Pi, you must keep `python3-rpi-lgpio` or use the older `python3-rpi.gpio` package.

3. **Desktop Branding**: All 10 `rpd-*` packages contain Raspberry Pi branding and can be completely removed if you're creating a custom-branded desktop environment.

4. **Repository Access**: To install any Pi-specific package, you must keep `raspberrypi-archive-keyring` to authenticate the Pi package repository.

5. **Performance**: Pi-optimized packages (`libreoffice-pi`, `linux-image-rpi-*`) are specifically tuned for Pi hardware and will outperform generic equivalents.

6. **EEPROM Critical**: For Raspberry Pi 4, 400, and 5, the `rpi-eeprom` package is critical for bootloader bug fixes and feature updates. Do not remove.

7. **Cloud Services**: `rpi-connect-lite` connects to Raspberry Pi Foundation cloud services. Remove if you want a fully offline/private system.

8. **Metapackages**: The `rpd-applications`, `rpd-developer`, `rpd-graphics`, and `rpd-utilities` packages are just metapackages (collections). They don't install unique software but pull in other packages that can be installed individually.
