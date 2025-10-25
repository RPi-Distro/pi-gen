# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

pi-gen is a tool for creating Raspberry Pi OS images and custom images based on Raspberry Pi OS. This repository builds 64-bit ARM images (from the `arm64` branch) while 32-bit images are built from the `master` branch.

## Build Commands

### Standard Build
```bash
# Edit config file first to set IMG_NAME and other variables
./build.sh
```

### Docker Build
```bash
# For systems without Debian-based OS or for isolation
./build-docker.sh

# Continue after fixing errors
CONTINUE=1 ./build-docker.sh

# Preserve container for incremental changes
PRESERVE_CONTAINER=1 ./build-docker.sh

# Clean rebuild of last stage only
CLEAN=1 ./build.sh
```

### Development Workflow for Specific Stages
```bash
# 1. Add SKIP_IMAGES to stages with EXPORT_* files to prevent image generation during development
touch ./stage2/SKIP_IMAGES ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

# 2. Add SKIP files to stages you don't want to build
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP

# 3. Initial full build
./build.sh

# 4. Add SKIP to earlier successful stages
touch ./stage0/SKIP ./stage1/SKIP

# 5. Modify and rebuild only the last stage
CLEAN=1 ./build.sh
```

## Architecture

### Stage-Based Build System

The build process iterates through stage directories (stage0-stage5) in alphanumeric order. Each stage builds upon the previous one using rsync to copy the rootfs.

**Stage Progression:**
- **stage0**: Bootstrap - Creates minimal filesystem via debootstrap. Installs raspberrypi-bootloader. NOT bootable.
- **stage1**: Truly minimal bootable system - Configures /etc/fstab, bootloader, networking, raspi-config
- **stage2**: Lite system - Produces Raspberry Pi OS Lite. Adds wireless/bluetooth, timezone/locale, fake-hwclock, swap
- **stage3**: Desktop system - Full desktop with X11, LXDE, web browsers, development tools
- **stage4**: Standard image - System for 4GB cards with documentation and user-friendly tools
- **stage5**: Full image - Additional development tools, email, Scratch, sonic-pi, office suite

### Stage Execution Flow

Within each stage directory:
1. `prerun.sh` runs (typically copies from previous stage)
2. Process each numbered subdirectory (00-*, 01-*, etc.) containing:
   - `00-debconf`: Debconf configuration passed to debconf-set-selections
   - `00-packages`: Packages to install with apt-get install -y
   - `00-packages-nr`: Packages to install with --no-install-recommends
   - `00-patches/`: Directory of quilt patches to apply
   - `00-run.sh`: Executable shell script (runs on host)
   - `00-run-chroot.sh`: Shell script run inside chroot
3. Check for EXPORT_IMAGE or EXPORT_NOOBS markers
4. Generate images if marked

**Important:** Subdirectories must be named with two-digit padded numbers at the beginning (00-, 01-, 02-, etc.)

### Key Build Scripts

- `build.sh`: Main build orchestrator (sources config, iterates stages, calls common functions)
- `scripts/common`: Shared functions including:
  - `bootstrap()`: Runs debootstrap with arm64 architecture
  - `copy_previous()`: Rsyncs previous stage rootfs
  - `on_chroot()`: Executes commands in chroot with proper mounts (proc, dev, sys, run, tmp)
  - `unmount()`: Safely unmounts chroot filesystems
  - `log()`: Timestamped logging

### Configuration

The `config` file (sourced by build.sh) sets environment variables:

**Essential variables:**
- `IMG_NAME`: Root name of the OS image (default: cros-$RELEASE-$ARCH)
- `RELEASE`: Debian release version (default: trixie for arm64 branch)
- `STAGE_LIST`: Override default stage order or add custom stages

**Customization variables:**
- `LOCALE_DEFAULT`, `TARGET_HOSTNAME`, `KEYBOARD_KEYMAP`, `KEYBOARD_LAYOUT`, `TIMEZONE_DEFAULT`
- `FIRST_USER_NAME`, `FIRST_USER_PASS`, `DISABLE_FIRST_BOOT_USER_RENAME`
- `ENABLE_SSH`, `PUBKEY_SSH_FIRST_USER`, `WPA_COUNTRY`

**Build control:**
- `WORK_DIR`: Build cache location (default: $BASE_DIR/work) - stores complete copy per stage
- `DEPLOY_DIR`: Output location (default: $BASE_DIR/deploy)
- `DEPLOY_COMPRESSION`: none|zip|gz|xz (default: zip)
- `ENABLE_CLOUD_INIT`: Install cloud-init and netplan (default: 1)

### Control Files

- `SKIP`: Place in stage directory to bypass that stage entirely
- `SKIP_IMAGES`: Place in stage to prevent image export even if EXPORT_IMAGE exists
- `EXPORT_IMAGE`: Marks stage for image generation
- `EXPORT_NOOBS`: Marks stage for NOOBS bundle generation

### Important Constraints

- Base path must NOT contain spaces (debootstrap limitation)
- WORK_DIR must be on a proper Linux filesystem, not NTFS
- Requires Debian-based OS released after 2017
- arm64 branch builds 64-bit images only; use master branch for 32-bit

## Dependencies

Install with: `apt install coreutils quilt parted qemu-user-static debootstrap zerofree zip dosfstools e2fsprogs libarchive-tools libcap2-bin grep rsync xz-utils file git curl bc gpg pigz xxd arch-test bmap-tools kmod`

See `depends` file for complete list in format `<tool>[:<debian-package>]`.

## Directory Structure

- `stage*/`: Build stages with numbered subdirectories
- `export-image/`: Scripts for image finalization (set-partuuid, network config, user-rename)
- `export-noobs/`: NOOBS bundle generation
- `scripts/`: Common functions and utilities
- `docs/`: Documentation for Computado Rita rebranding and package information
- `work/`: Build cache (gitignored, can be large - tens of GB)
- `deploy/`: Output images (gitignored)

## Additional Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[docs/REBRANDING_CHANGES.md](docs/REBRANDING_CHANGES.md)** - Complete rebranding summary from Raspberry Pi to Computado Rita
- **[docs/RASPBERRY_PI_IMAGES_INVENTORY.md](docs/RASPBERRY_PI_IMAGES_INVENTORY.md)** - Inventory of all Pi-branded images and logos
- **[docs/RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md](docs/RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md)** - Guide for text replacements
- **[docs/RASPBERRY_PI_SPECIFIC_PACKAGES.md](docs/RASPBERRY_PI_SPECIFIC_PACKAGES.md)** - Documentation of Pi-specific packages
- **[docs/RASPBIAN_TO_CROS_REPLACEMENTS.md](docs/RASPBIAN_TO_CROS_REPLACEMENTS.md)** - Raspbian/RaspiOS to CROS replacement guide
