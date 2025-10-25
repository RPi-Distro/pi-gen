# Raspberry Pi Images Inventory

This document lists all Raspberry Pi branded images, logos, and visual assets in this repository that may need to be replaced in future builds.

## Direct Image Files in Repository

### NOOBS OS Icon
- **Location**: `/export-noobs/00-release/files/OS.png`
- **Size**: 1.8 KB
- **Dimensions**: Unknown (PNG format)
- **Usage**: Operating system icon displayed in NOOBS (New Out Of Box Software) installer
- **When Used**: Copied to NOOBS directory during export and renamed to `${NOOBS_NAME// /_}.png`
- **Script Reference**: `export-noobs/00-release/00-run.sh:8,25`
- **Purpose**: Visual identifier for the OS in the NOOBS boot menu

### NOOBS Marketing Slides
Located in `/export-noobs/00-release/files/marketing/slides_vga/`

1. **Slide A.png**
   - Size: 51 KB
   - Usage: Marketing/information slide shown during NOOBS installation

2. **Slide B.png**
   - Size: 49 KB
   - Usage: Marketing/information slide shown during NOOBS installation

3. **Slide C.png**
   - Size: 105 KB
   - Usage: Marketing/information slide shown during NOOBS installation

4. **Slide D.png**
   - Size: 94 KB
   - Usage: Marketing/information slide shown during NOOBS installation

5. **Slide E.png**
   - Size: 80 KB
   - Usage: Marketing/information slide shown during NOOBS installation

6. **Slide F.png**
   - Size: 66 KB
   - Usage: Marketing/information slide shown during NOOBS installation

7. **Slide G.png**
   - Size: 105 KB
   - Usage: Marketing/information slide shown during NOOBS installation

**Total Marketing Slides Size**: ~550 KB
**When Used**: Packaged into `marketing.tar` during NOOBS export (export-noobs/00-release/00-run.sh:11)
**Purpose**: Provide visual information to users during OS installation via NOOBS

---

## Images Delivered via Debian Packages

These packages are installed during the build process and contain Raspberry Pi branded images, themes, icons, and visual assets.

### rpd-theme
- **Stage**: stage3 (Desktop system)
- **Package File**: `stage3/00-install-packages/00-packages:2`
- **Type**: Debian package from Raspberry Pi repositories
- **Contents**: Raspberry Pi Desktop theme including:
  - Desktop wallpapers
  - Window manager themes
  - Icon sets
  - GTK themes
  - Application styling
  - Branding elements
- **Purpose**: Provides the complete Raspberry Pi Desktop visual experience
- **Installation**: Installed with recommended dependencies via apt-get

### rpd-preferences
- **Stage**: stage3 (Desktop system)
- **Package File**: `stage3/00-install-packages/00-packages:1`
- **Type**: Debian package from Raspberry Pi repositories
- **Contents**: Desktop preferences and configurations (may include default wallpapers/backgrounds)
- **Purpose**: Sets default desktop preferences for Raspberry Pi OS
- **Installation**: Installed with recommended dependencies via apt-get

---

## Other Raspberry Pi Branded/Related Packages

While these packages may not primarily contain images, they could include icons, logos, or visual elements:

### System Packages
- **raspberrypi-sys-mods** (stage2/01-sys-tweaks/00-packages)
  - System modifications specific to Raspberry Pi
  - May include boot splash screens or system icons

- **raspberrypi-net-mods** (stage2/01-sys-tweaks/00-packages)
  - Network modifications
  - Potentially includes network-related icons

### Configuration Tools
- **raspi-config** (stage1/03-install-packages/00-packages)
  - Configuration utility
  - May have associated icons or branding

### Hardware-Specific Packages
- **rpi-eeprom** (stage2/01-sys-tweaks/00-packages)
  - EEPROM firmware updater
  - Could include utility icons

- **rpi-update** (stage2/01-sys-tweaks/00-packages)
  - Firmware update tool
  - May have associated branding

---

## Summary

### Images Found Directly in Repository
- **Total Image Files**: 8 PNG files
- **Total Size**: ~552 KB
- **Primary Use Cases**:
  - NOOBS installer branding (OS icon)
  - Installation slideshow content (7 marketing slides)

### Images in Packages
- **Primary Package**: `rpd-theme` - Contains the bulk of desktop visual assets
- **Secondary Package**: `rpd-preferences` - May contain default backgrounds
- **System Packages**: Multiple packages may contain icons/logos

### Replacement Strategy

To replace Raspberry Pi branded images in future builds:

1. **Replace Direct Images**:
   - Update `/export-noobs/00-release/files/OS.png` with new OS icon
   - Update all 7 marketing slide images in `/export-noobs/00-release/files/marketing/slides_vga/`

2. **Replace Package-Delivered Images**:
   - **Option A**: Fork and modify the `rpd-theme` package to use custom branding
   - **Option B**: Create a custom theme package and install it after rpd-theme
   - **Option C**: Add post-install scripts to replace specific files after package installation

3. **Consider Additional Packages**:
   - Review installed packages for additional branding (raspberrypi-sys-mods, etc.)
   - Check boot splash screens (plymouth themes if installed)
   - Verify desktop icons and application launchers

### Files to Monitor

When auditing for Raspberry Pi branding, check:
- `/usr/share/pixmaps/` (application icons)
- `/usr/share/backgrounds/` (desktop wallpapers)
- `/usr/share/themes/` (GTK/window themes)
- `/usr/share/icons/` (icon themes)
- `/usr/share/plymouth/themes/` (boot splash - if plymouth is installed)
- `/boot/firmware/` (boot partition files)

### Build Integration Notes

- NOOBS images are only included if a stage has `EXPORT_NOOBS` file
- Marketing slides are tar-archived during the export process
- Desktop theme packages are only installed in stage3+ (Desktop and Full images)
- Stage2 (Lite) images do not include desktop theming packages
