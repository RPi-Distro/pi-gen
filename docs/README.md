# Computado Rita Documentation

This directory contains comprehensive documentation for the Computado Rita OS build system, including rebranding information and package documentation.

**Project**: Computado Rita OS (CROS)  
**Contact**: @computadorita.cr  
**Website**: https://computadorita.cr/

---

## 📚 Documentation Files

### Rebranding Documentation

1. **[REBRANDING_CHANGES.md](REBRANDING_CHANGES.md)**
   - Complete summary of all rebranding changes
   - Lists every modification from "Raspberry Pi" to "Computado Rita"
   - Includes verification checklist and next steps
   - **Start here** for an overview of the rebranding

2. **[RASPBIAN_TO_CROS_REPLACEMENTS.md](RASPBIAN_TO_CROS_REPLACEMENTS.md)**
   - Detailed documentation of Raspbian/RaspiOS → CROS replacements
   - Shows before/after code for every change
   - Explains capitalization patterns applied
   - Includes verification commands

3. **[RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md](RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md)**
   - Comprehensive guide to all "Raspberry Pi" text occurrences
   - Categorizes replacements as safe, unsafe, or cautionary
   - Includes actionable checklist for replacements
   - Details package names that cannot be changed

### Technical Documentation

4. **[RASPBERRY_PI_SPECIFIC_PACKAGES.md](RASPBERRY_PI_SPECIFIC_PACKAGES.md)**
   - Documents all 35 Raspberry Pi-specific packages
   - Categorized by purpose (firmware, hardware, desktop, etc.)
   - Indicates which packages are critical vs optional
   - Provides alternatives and replacement strategies
   - **Essential reading** for understanding package dependencies

5. **[RASPBERRY_PI_IMAGES_INVENTORY.md](RASPBERRY_PI_IMAGES_INVENTORY.md)**
   - Complete inventory of all Pi-branded images
   - Lists location, size, and usage of each image
   - Covers both direct image files and package-delivered images
   - Includes replacement strategy recommendations

6. **[IMAGE_REBRANDING_GUIDE.md](IMAGE_REBRANDING_GUIDE.md)** ⭐ NEW
   - **Complete guide to replacing all images** with Computado Rita branding
   - Step-by-step instructions for automated image replacement
   - Uses the SVG assets (CRIcon, CRbanner, CRWallPaper)
   - Creates OS icon and marketing slides automatically
   - Includes customization and troubleshooting

---

## 🎨 Visual Assets

This directory also contains Computado Rita branding assets:

- **CRbanner.svg** - Computado Rita banner
- **CRIcon.svg** - Computado Rita icon
- **CRWallPaper.svg** - Computado Rita wallpaper

These assets can be used to replace Raspberry Pi branding in:
- NOOBS installer (OS.png)
- Marketing slides (slides_vga/*.png)
- Desktop wallpapers and themes

---

## 🔍 Quick Reference

### Current Configuration

The build is configured for:
- **OS Name**: CROS
- **Hostname**: computadorita
- **Locale**: Spanish (Costa Rica)
- **Contact**: @computadorita.cr
- **URL**: https://computadorita.cr/

### Key Changes Summary

| Original | Replaced With |
|----------|---------------|
| Raspberry Pi | Computado Rita |
| Raspberry Pi OS | Computado Rita OS |
| raspios | cros |
| Raspbian | CROS |
| raspberrypi (hostname) | computadorita |
| raspbian.org | computadorita.cr |

### Files Modified

- `config` - Added header and contact info
- `build.sh` - Updated OS name and default image name
- `scripts/dependencies_check` - Updated error messages
- `stage2/04-cloud-init/` - Renamed config files
- `export-noobs/00-release/files/os.json` - Updated URL
- `README.md` - Updated examples
- `CLAUDE.md` - Updated defaults

---

## 📖 How to Use This Documentation

### If You're Building the Image:
1. Start with [REBRANDING_CHANGES.md](REBRANDING_CHANGES.md)
2. Review the verification checklist
3. Check [RASPBERRY_PI_IMAGES_INVENTORY.md](RASPBERRY_PI_IMAGES_INVENTORY.md) to replace visual assets
4. Run your build

### If You're Customizing Further:
1. Read [RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md](RASPBERRY_PI_TEXT_REPLACEMENT_GUIDE.md) for safe text replacements
2. Consult [RASPBERRY_PI_SPECIFIC_PACKAGES.md](RASPBERRY_PI_SPECIFIC_PACKAGES.md) to understand package dependencies
3. Review [RASPBIAN_TO_CROS_REPLACEMENTS.md](RASPBIAN_TO_CROS_REPLACEMENTS.md) for OS naming patterns

### If You're Removing Pi Dependencies:
1. Read [RASPBERRY_PI_SPECIFIC_PACKAGES.md](RASPBERRY_PI_SPECIFIC_PACKAGES.md)
2. Note which packages are critical (firmware, bootloader)
3. Identify safe-to-remove packages (desktop themes, optional tools)
4. Test thoroughly after removing packages

---

## 🚀 Build Instructions

To build Computado Rita OS:

```bash
# Navigate to pi-gen directory
cd /home/svvs/pi-gen

# Build natively (requires Debian-based system)
sudo ./build.sh

# Or build with Docker
./build-docker.sh
```

Output will be in `deploy/CROS-YYYY-MM-DD-arm64.img.xz`

---

## 🔗 External Resources

- **Main README**: [../README.md](../README.md) - Original pi-gen documentation
- **CLAUDE.md**: [../CLAUDE.md](../CLAUDE.md) - AI assistant guide for this codebase
- **Config File**: [../config](../config) - Build configuration

---

**Maintained by**: Computado Rita Project  
**Based on**: pi-gen (Raspberry Pi image builder)  
**License**: See [../LICENSE](../LICENSE)
