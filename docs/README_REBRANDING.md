# Computado Rita OS - Quick Start

**Welcome!** This is a rebranded version of pi-gen that builds **Computado Rita OS** instead of Raspberry Pi OS.

🇨🇷 **Diseñado para Costa Rica** | Designed for Costa Rica
📧 **Contact**: @computadorita.cr
🌐 **Website**: https://computadorita.cr/

---

## 🚀 Quick Start

### 1. Brand the Images (Required First Step)

Before building, run this command to replace all Raspberry Pi images with Computado Rita branding:

```bash
./setup_and_brand_images.sh
```

This creates:
- ✅ Computado Rita OS icon (40x40)
- ✅ 7 marketing slides in Spanish (640x480)
- ✅ Automatic backup of original images

### 2. Build Your Image

```bash
# Standard build (requires Debian-based system)
sudo ./build.sh

# Or Docker build (works on any Linux)
./build-docker.sh
```

### 3. Find Your Image

Your image will be in `deploy/CROS-YYYY-MM-DD-arm64.img.xz`

---

## 📚 Documentation

Complete rebranding documentation is in the `docs/` directory:

- **[docs/README.md](docs/README.md)** - Start here for an overview
- **[docs/IMAGE_REBRANDING_GUIDE.md](docs/IMAGE_REBRANDING_GUIDE.md)** - Image branding instructions
- **[docs/REBRANDING_CHANGES.md](docs/REBRANDING_CHANGES.md)** - Complete list of all changes

---

## ✅ What's Been Rebranded

| Original | Rebranded |
|----------|-----------|
| Raspberry Pi | Computado Rita |
| Raspberry Pi OS | Computado Rita OS |
| raspios | cros |
| raspberrypi (hostname) | computadorita |
| raspbian.org | computadorita.cr |

**Total Changes**: 13 text replacements + automated image generation

---

## 🎨 Branding Assets

The `docs/` directory contains:
- **CRIcon.svg** - Computado Rita icon
- **CRbanner.svg** - Banner
- **CRWallPaper.svg** - Wallpaper

These are automatically converted to NOOBS installer images when you run `./setup_and_brand_images.sh`

---

## ⚙️ Current Configuration

Located in `config`:

- **OS Name**: CROS
- **Hostname**: computadorita
- **Locale**: Spanish (Costa Rica)
- **Timezone**: America/Costa_Rica
- **Keyboard**: Spanish (Costa Rica)
- **Contact**: @computadorita.cr

---

## 🔧 Technical Details

### Base System
- **Based on**: pi-gen (Raspberry Pi image builder)
- **Debian Version**: Trixie (current)
- **Architecture**: ARM64 (64-bit)
- **Target Hardware**: Raspberry Pi 3/4/5, Zero 2

### Build Output
- **Image Format**: .img.xz (compressed)
- **Installer**: NOOBS compatible
- **Size**: ~2-4GB (depending on stages included)

---

## 📦 Package Notes

**Important**: Some package names cannot be changed because they come from official Raspberry Pi repositories:

- `raspberrypi-archive-keyring` - Repository authentication
- `raspi-firmware` - Boot firmware
- `linux-image-rpi-*` - Optimized kernels
- `rpi-eeprom` - Bootloader (Pi 4/5)
- All `rpd-*` packages - Desktop theme (can be removed)

See [docs/RASPBERRY_PI_SPECIFIC_PACKAGES.md](docs/RASPBERRY_PI_SPECIFIC_PACKAGES.md) for complete list.

---

## 🛠️ Build Stages

The build process has 6 stages (0-5):

- **Stage 0**: Bootstrap (minimal filesystem)
- **Stage 1**: Basic bootable system
- **Stage 2**: Lite system ← **Recommended for servers**
- **Stage 3**: Desktop environment
- **Stage 4**: Standard applications
- **Stage 5**: Full system with all apps

To build only up to stage 2 (Lite):
```bash
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
sudo ./build.sh
```

---

## 📝 For More Information

- **Original pi-gen docs**: [README.md](README.md)
- **AI assistant guide**: [CLAUDE.md](CLAUDE.md)
- **Rebranding summary**: [IMAGE_REBRANDING_SUMMARY.md](IMAGE_REBRANDING_SUMMARY.md)

---

## 🎉 Ready to Build!

1. ✅ Run `./setup_and_brand_images.sh` (IMPORTANT!)
2. ✅ Run `sudo ./build.sh` or `./build-docker.sh`
3. ✅ Your Computado Rita OS image will be in `deploy/`

**¡Pura vida!** 🇨🇷

---

**Maintained by**: Computado Rita Project
**Original pi-gen by**: Raspberry Pi Foundation
**License**: See LICENSE file
