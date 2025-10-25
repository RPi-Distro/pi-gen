# Computado Rita Image Rebranding Guide

This document explains how to rebrand all Raspberry Pi images with Computado Rita branding.

**Project**: Computado Rita OS (CROS)
**Contact**: @computadorita.cr
**Date**: October 25, 2025

---

## 📋 Overview

This guide covers replacing all Raspberry Pi branded images in the NOOBS installer with Computado Rita branding using the SVG assets in the `docs/` directory.

### Images That Will Be Replaced

1. **OS Icon** (`export-noobs/00-release/files/OS.png`)
   - 40x40 pixel icon shown in NOOBS installer
   - Converted from `docs/CRIcon.svg`

2. **Marketing Slides** (`export-noobs/00-release/files/marketing/slides_vga/*.png`)
   - 7 slides (A-G) at 640x480 resolution (VGA)
   - Shown during OS installation
   - Created with Computado Rita branding and Spanish text

### Source Assets

All images are generated from these SVG files in the `docs/` directory:

- **CRIcon.svg** - Computado Rita icon (used for OS icon)
- **CRbanner.svg** - Computado Rita banner
- **CRWallPaper.svg** - Computado Rita wallpaper

---

## 🚀 Quick Start

### Automatic Method (Recommended)

Run the automated setup script:

```bash
cd /home/svvs/pi-gen
./setup_and_brand_images.sh
```

This script will:
1. ✅ Install required Python packages (cairosvg, pillow)
2. ✅ Backup original Raspberry Pi images
3. ✅ Convert SVG files to PNG format
4. ✅ Create OS icon (40x40)
5. ✅ Create 7 marketing slides in Spanish
6. ✅ Replace all images with Computado Rita branding

**That's it!** Your images are now branded.

---

## 📦 Manual Method

If you prefer to run steps manually:

### Step 1: Install Dependencies

```bash
# Install pip if needed
sudo apt-get update
sudo apt-get install -y python3-pip

# Install required Python packages
pip3 install --user cairosvg pillow
```

### Step 2: Run the Branding Script

```bash
python3 create_branded_images.py
```

### Step 3: Verify Results

```bash
# Check OS icon was created
ls -lh export-noobs/00-release/files/OS.png

# Check marketing slides were created
ls -lh export-noobs/00-release/files/marketing/slides_vga/*.png

# Check backups were created
ls -lh original_images_backup/
```

---

## 📸 What Gets Created

### 1. OS Icon (OS.png)

**Location**: `export-noobs/00-release/files/OS.png`
**Size**: 40x40 pixels
**Source**: Converted from `docs/CRIcon.svg`
**Usage**: Displayed in NOOBS OS selection menu

**Specifications**:
- Format: PNG with transparency
- Resolution: 40x40 pixels
- Optimized for file size (~1-2KB)

### 2. Marketing Slides (A.png - G.png)

**Location**: `export-noobs/00-release/files/marketing/slides_vga/`
**Size**: 640x480 pixels (VGA)
**Source**: Generated with Computado Rita branding
**Usage**: Shown during OS installation in NOOBS

#### Slide Content (Spanish)

| Slide | Title | Subtitle | Content |
|-------|-------|----------|---------|
| **A** | Bienvenido a Computado Rita | Sistema Operativo Educativo | Diseñado para Costa Rica |
| **B** | Fácil de Usar | Interfaz Intuitiva | Perfecto para estudiantes y educadores |
| **C** | Software Libre | Código Abierto | Basado en Debian y tecnología Raspberry Pi |
| **D** | Desarrollo y Programación | Python, Scratch, y más | Herramientas educativas incluidas |
| **E** | Conectividad | WiFi y Bluetooth | Listo para conectar y aprender |
| **F** | Multimedia | Audio y Video | Experimenta y crea contenido |
| **G** | Comunidad | computadorita.cr | Únete a nuestra comunidad |

**Design Elements**:
- Gradient background (dark blue theme)
- Computado Rita icon in top-left corner
- White title text (48pt bold)
- Cyan subtitle text (32pt)
- Light gray body text (24pt)
- Footer with "Computado Rita OS • @computadorita.cr"

---

## 💾 Backup Information

### Automatic Backups

The branding script automatically backs up original images to:

```
original_images_backup/
├── OS.png.original              (original Raspberry Pi icon)
├── A.png.original               (original slide A)
├── B.png.original               (original slide B)
├── C.png.original               (original slide C)
├── D.png.original               (original slide D)
├── E.png.original               (original slide E)
├── F.png.original               (original slide F)
└── G.png.original               (original slide G)
```

### Restore Original Images

If you need to restore the original Raspberry Pi images:

```bash
cd /home/svvs/pi-gen
cp original_images_backup/*.original export-noobs/00-release/files/
cd export-noobs/00-release/files
for f in *.original; do mv "$f" "${f%.original}"; done

cp original_images_backup/*.original marketing/slides_vga/
cd marketing/slides_vga
for f in *.original; do mv "$f" "${f%.original}"; done
```

---

## 🔧 Customization

### Editing Slide Content

To customize the marketing slide messages, edit the `SLIDE_MESSAGES` dictionary in `create_branded_images.py`:

```python
SLIDE_MESSAGES = {
    'A': {
        'title': 'Your Title',
        'subtitle': 'Your Subtitle',
        'text': 'Your text content'
    },
    # ... edit other slides
}
```

Then re-run the script:
```bash
python3 create_branded_images.py
```

### Using Different SVG Source Files

To use different SVG files for branding:

1. Place your custom SVG files in the `docs/` directory
2. Update the file paths in `create_branded_images.py`:
   ```python
   CR_ICON_SVG = DOCS_DIR / "YourIcon.svg"
   CR_BANNER_SVG = DOCS_DIR / "YourBanner.svg"
   CR_WALLPAPER_SVG = DOCS_DIR / "YourWallpaper.svg"
   ```
3. Re-run the script

### Changing Image Sizes

If you need different image sizes (e.g., for high-DPI displays):

Edit `create_branded_images.py`:

```python
# For OS icon (default is 40x40)
img = img.resize((80, 80), Image.Resampling.LANCZOS)  # Change to desired size

# For marketing slides (default is 640x480)
width, height = 1280, 960  # Change to desired resolution
```

---

## 🧪 Testing

### Test in NOOBS

To see your branded images in action:

1. Build your image:
   ```bash
   ./build.sh
   ```

2. Copy the NOOBS files to an SD card

3. Boot a Raspberry Pi with the SD card

4. You should see:
   - Computado Rita icon in OS selection menu
   - Branded marketing slides during installation

### Preview Images

To preview the generated images:

```bash
# View OS icon
xdg-open export-noobs/00-release/files/OS.png

# View marketing slides
xdg-open export-noobs/00-release/files/marketing/slides_vga/A.png
```

---

## 🐛 Troubleshooting

### Script Fails with "Module not found"

**Problem**: Missing Python packages

**Solution**:
```bash
pip3 install --user cairosvg pillow
# Or with sudo if needed:
sudo pip3 install cairosvg pillow
```

### "SVG file not found" Error

**Problem**: SVG source files missing

**Solution**: Ensure SVG files exist in `docs/`:
```bash
ls -l docs/CR*.svg
```

They should show:
- `docs/CRIcon.svg`
- `docs/CRbanner.svg`
- `docs/CRWallPaper.svg`

### Images Look Blurry

**Problem**: Low resolution or bad scaling

**Solution**:
- Ensure your SVG files are high quality
- Increase the intermediate resolution in the script
- Edit `create_branded_images.py` and increase `output_width` values

### Permission Denied

**Problem**: Cannot write to image directories

**Solution**:
```bash
# Make sure you own the files
sudo chown -R $USER:$USER /home/svvs/pi-gen/export-noobs
chmod u+w export-noobs/00-release/files/OS.png
chmod u+w export-noobs/00-release/files/marketing/slides_vga/*.png
```

---

## 📝 Technical Details

### Image Conversion Process

1. **SVG to PNG Conversion**
   - Uses `cairosvg` to render SVG files to PNG
   - Renders at 2x resolution then scales down for better quality

2. **Icon Creation**
   - Renders CRIcon.svg at 80x80
   - Scales down to 40x40 with LANCZOS resampling (high quality)
   - Optimizes PNG for minimal file size

3. **Marketing Slide Creation**
   - Creates 640x480 RGB canvas
   - Applies gradient background
   - Overlays icon from CRIcon.svg
   - Renders text with TrueType fonts (DejaVu Sans)
   - Optimizes PNG output

### Dependencies

- **Python 3** (3.6+)
- **cairosvg** (0.5.0+) - SVG to PNG conversion
- **Pillow** (PIL, 8.0.0+) - Image manipulation
- **DejaVu Sans fonts** (optional but recommended) - For text rendering

### File Formats

All output images use:
- **Format**: PNG (Portable Network Graphics)
- **Compression**: Optimized for file size
- **Transparency**: Supported (used in OS icon)
- **Color space**: RGB (slides), RGBA (icon)

---

## 🔗 Related Documentation

- **[RASPBERRY_PI_IMAGES_INVENTORY.md](RASPBERRY_PI_IMAGES_INVENTORY.md)** - Original inventory of Pi images
- **[REBRANDING_CHANGES.md](REBRANDING_CHANGES.md)** - Complete rebranding summary
- **[README.md](README.md)** - Main documentation index

---

## ✅ Verification Checklist

After running the branding script:

- [ ] `original_images_backup/` directory created with 8 backup files
- [ ] `export-noobs/00-release/files/OS.png` is 40x40 and shows Computado Rita icon
- [ ] `export-noobs/00-release/files/marketing/slides_vga/` has 7 PNG files (A-G)
- [ ] All marketing slides are 640x480 and show Computado Rita branding
- [ ] Marketing slides display Spanish text correctly
- [ ] Build process completes successfully
- [ ] NOOBS installer shows branded images when tested

---

## 🎉 Success!

Once complete, your pi-gen build will produce Raspberry Pi OS images with:

✅ Computado Rita branding in NOOBS installer
✅ Custom OS icon
✅ Spanish language marketing slides
✅ Professional appearance
✅ Costa Rica localization

**Your Computado Rita OS is ready to build!**

---

**Project**: Computado Rita OS
**Website**: https://computadorita.cr/
**Contact**: @computadorita.cr
**Generated**: October 25, 2025
