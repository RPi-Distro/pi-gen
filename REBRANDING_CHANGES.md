# Computado Rita Rebranding Changes

This document summarizes all changes made to rebrand from "Raspberry Pi" to "Computado Rita".

**Date**: October 25, 2025
**Contact**: @computadorita.cr
**Website**: https://computadorita.cr/

---

## 📋 Quick Summary

All instances of:
- "Raspberry Pi" → "Computado Rita"
- "Raspberry Pi OS" → "Computado Rita OS"
- "raspios" → "cros"
- "Raspbian" → "CROS"

**Total Changes**: 13 replacements in code and documentation
**See Also**: `RASPBIAN_TO_CROS_REPLACEMENTS.md` for detailed Raspbian/RaspiOS replacement documentation

---

## ✅ Changes Completed

### 1. Configuration File - `config`
**Added header with contact information:**
```bash
# Computado Rita OS Configuration
# Contact: @computadorita.cr
# Website: https://computadorita.cr/
```

**Existing configuration (already set):**
- `IMG_NAME="CROS"`
- `PI_GEN_RELEASE="CROS"`
- `TARGET_HOSTNAME="computadorita"`
- Localization for Costa Rica (es_CR, America/Costa_Rica)

### 2. Build Script - `build.sh:268`
**Changed error message:**
- **Before**: `"On Raspberry Pi OS (64-bit), you can switch to..."`
- **After**: `"On Computado Rita OS (64-bit), you can switch to..."`

### 3. Cloud-Init Configuration Files
**Renamed file:**
- **Before**: `stage2/04-cloud-init/files/99_raspberry-pi.cfg`
- **After**: `stage2/04-cloud-init/files/99_computado-rita.cfg`

**Updated install script** (`stage2/04-cloud-init/01-run.sh:8`):
- **Before**: `files/99_raspberry-pi.cfg`
- **After**: `files/99_computado-rita.cfg`

### 4. NOOBS Configuration - `export-noobs/00-release/files/os.json`
**Updated URL:**
- **Before**: `"url": "http://www.raspbian.org/"`
- **After**: `"url": "https://computadorita.cr/"`

### 5. Mathematica EULA - `stage2/03-accept-mathematica-eula/00-debconf`
**Updated comment:**
- **Before**: `# Do you accept the Wolfram - Raspberry Pi® Bundle License Agreement?`
- **After**: `# Do you accept the Wolfram - Computado Rita Bundle License Agreement?`

### 6. RaspiOS/Raspbian to CROS Replacements

**File**: `build.sh:182` - Default image name
- **Before**: `raspios-$RELEASE-$ARCH`
- **After**: `cros-$RELEASE-$ARCH`

**File**: `scripts/dependencies_check:26` - Error message
- **Before**: `Debian/Raspbian systems`
- **After**: `Debian/CROS systems`

**File**: `README.md` - Documentation examples (4 instances)
- All examples updated from `raspios` to `cros`
- Example text changed from "Raspberry Pi OS" to "Computado Rita OS"

**File**: `CLAUDE.md` - AI documentation (1 instance)
- Default value updated from `raspios-$RELEASE-$ARCH` to `cros-$RELEASE-$ARCH`

**See**: `RASPBIAN_TO_CROS_REPLACEMENTS.md` for complete details

---

## ⚠️ Important: What Was NOT Changed

### Cannot Be Changed (Technical Limitations)

#### Package Names
All Raspberry Pi-specific package names **remain unchanged** because they must match actual Debian package names:
- `raspberrypi-archive-keyring`
- `raspberrypi-sys-mods`
- `raspberrypi-net-mods`
- `raspi-firmware`
- `linux-image-rpi-v8`
- `linux-image-rpi-2712`
- `rpi-eeprom`
- `rpi-connect-lite`
- `rpi-update`
- All `rpd-*` packages (desktop theme packages)
- See `RASPBERRY_PI_SPECIFIC_PACKAGES.md` for complete list

#### Repository URLs
Must remain unchanged to access Raspberry Pi package repositories:
- `http://archive.raspberrypi.com/debian/` in `stage0/00-configure-apt/files/raspi.sources`
- GitHub URLs: `github.com/raspberrypi/*` in `export-image/05-finalise/01-run.sh`

#### System Paths
Package-installed paths cannot be changed:
- `/usr/share/doc/raspberrypi-kernel/`
- `/usr/share/keyrings/raspberrypi-archive-keyring.pgp`

#### Files
- `stage0/00-configure-apt/files/raspberrypi-archive-keyring.pgp` - Cryptographic keyring file
- `stage0/files/raspberrypi.gpg` - GPG key file

---

## 🎨 Additional Branding Opportunities

### Images & Visual Assets
See `RASPBERRY_PI_IMAGES_INVENTORY.md` for detailed image replacement guide:

**Direct image files to replace:**
1. `/export-noobs/00-release/files/OS.png` (1.8 KB) - NOOBS OS icon
2. `/export-noobs/00-release/files/marketing/slides_vga/*.png` (7 slides, ~550 KB) - Installation slideshow

**Packages containing visual branding:**
- `rpd-theme` - Desktop theme with Raspberry Pi branding
- `rpd-preferences` - Desktop defaults and wallpapers

### NOOBS Default Password
**Current**: `"password": "raspberry"` in `export-noobs/00-release/files/os.json:5`
**Recommendation**: Change to a secure default or remove this field
**Status**: ⚠️ Not changed - awaiting decision on new password

---

## 📝 Build Configuration Summary

Your current config creates an image with:
- **OS Name**: CROS
- **Release Name**: CROS
- **Hostname**: computadorita
- **Locale**: Spanish (Costa Rica)
- **Timezone**: America/Costa_Rica
- **Keyboard**: Spanish (Costa Rica)
- **WiFi Country**: CR (Costa Rica)
- **SSH**: Enabled
- **Compression**: xz

---

## 🚀 Next Steps for Complete Rebranding

### 1. Replace Visual Assets (High Priority)
```bash
# Replace NOOBS OS icon
cp /path/to/your/os-icon.png export-noobs/00-release/files/OS.png

# Replace marketing slides (7 files: A.png through G.png)
cp /path/to/your/slides/*.png export-noobs/00-release/files/marketing/slides_vga/
```

### 2. Remove or Replace Raspberry Pi Desktop Theme (Optional)
To remove Raspberry Pi branding from desktop environment:

**Option A: Remove rpd-theme entirely**
```bash
# Remove from stage3/00-install-packages/00-packages
sed -i '/rpd-theme/d' stage3/00-install-packages/00-packages
sed -i '/rpd-preferences/d' stage3/00-install-packages/00-packages

# Install alternative theme
echo "arc-theme" >> stage3/00-install-packages/00-packages
echo "papirus-icon-theme" >> stage3/00-install-packages/00-packages
```

**Option B: Fork and customize rpd-theme**
- Create custom Debian package with your branding
- Host on your own repository
- Update package sources to point to your repository

### 3. Change NOOBS Default Password
Edit `export-noobs/00-release/files/os.json:5`:
```json
"password": "YOUR_SECURE_PASSWORD",
```
Or remove the password field entirely for maximum security.

### 4. Remove Raspberry Pi-Specific Packages (If Not Needed)
If building for non-Pi hardware, remove Pi-specific packages:
- See `RASPBERRY_PI_SPECIFIC_PACKAGES.md` for detailed removal guide
- Keep essential firmware if building for Raspberry Pi hardware

### 5. Create Custom Boot Splash (Optional)
- Replace Plymouth theme if installed
- Add custom boot logo to firmware partition

### 6. Update Documentation Files
Review and update:
- `README.md` - Update project description
- `LICENSE` - Keep original Pi Gen license, add your modifications
- Add `CONTRIBUTORS.md` or `AUTHORS.md` with your information

---

## 📚 Reference Documents

This repository now includes comprehensive documentation:

1. **CLAUDE.md** - Guide for AI assistants working with this codebase
2. **RASPBERRY_PI_IMAGES_INVENTORY.md** - Complete image asset inventory
3. **RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md** - Text replacement locations guide
4. **RASPBERRY_PI_SPECIFIC_PACKAGES.md** - Pi-specific package documentation
5. **REBRANDING_CHANGES.md** - This document

---

## ✅ Verification Checklist

Before building your Computado Rita image:

- [x] Config file updated with Computado Rita branding
- [x] Error messages changed from "Raspberry Pi" to "Computado Rita"
- [x] Cloud-init config file renamed
- [x] NOOBS URL updated to computadorita.cr
- [x] Mathematica EULA comment updated
- [ ] OS icon replaced (export-noobs/00-release/files/OS.png)
- [ ] Marketing slides replaced (7 PNG files)
- [ ] NOOBS default password changed or removed
- [ ] Desktop theme packages reviewed (rpd-theme, rpd-preferences)
- [ ] Tested build completes successfully
- [ ] Tested image boots on target hardware

---

## 🔧 Build Command

To build your Computado Rita OS image:

```bash
# For native build
sudo ./build.sh

# For Docker build
./build-docker.sh
```

The resulting image will be in the `deploy/` directory with the name `CROS-<date>-arm64.img.xz`

---

## 📞 Support

**Project**: Computado Rita OS
**Based on**: pi-gen (Raspberry Pi image builder)
**Contact**: @computadorita.cr
**Website**: https://computadorita.cr/

---

*This rebranding maintains full compatibility with Raspberry Pi hardware while presenting the Computado Rita brand identity.*
