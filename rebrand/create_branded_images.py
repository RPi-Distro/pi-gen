#!/usr/bin/env python3
"""
Computado Rita Image Branding Script

This script converts the SVG branding files to PNG images for use in NOOBS.
It requires: pip install cairosvg pillow

Usage:
    python3 create_branded_images.py
"""

import os
import sys
from pathlib import Path

try:
    import cairosvg
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("ERROR: Required packages not installed")
    print("Please run: pip install cairosvg pillow")
    sys.exit(1)

# Paths
BASE_DIR = Path(__file__).parent
DOCS_DIR = BASE_DIR / "docs"
NOOBS_DIR = BASE_DIR / "export-noobs" / "00-release" / "files"
MARKETING_DIR = NOOBS_DIR / "marketing" / "slides_vga"
BACKUP_DIR = BASE_DIR / "original_images_backup"

# SVG source files
CR_ICON_SVG = DOCS_DIR / "CRIcon.svg"
CR_BANNER_SVG = DOCS_DIR / "CRbanner.svg"
CR_WALLPAPER_SVG = DOCS_DIR / "CRWallPaper.svg"

# Target files
OS_ICON_PNG = NOOBS_DIR / "OS.png"

# Marketing slide messages
SLIDE_MESSAGES = {
    'A': {
        'title': 'Bienvenido a Computado Rita',
        'subtitle': 'Sistema Operativo Educativo',
        'text': 'Diseñado para Costa Rica'
    },
    'B': {
        'title': 'Fácil de Usar',
        'subtitle': 'Interfaz Intuitiva',
        'text': 'Perfecto para estudiantes y educadores'
    },
    'C': {
        'title': 'Software Libre',
        'subtitle': 'Código Abierto',
        'text': 'Basado en Debian y tecnología Raspberry Pi'
    },
    'D': {
        'title': 'Desarrollo y Programación',
        'subtitle': 'Python, Scratch, y más',
        'text': 'Herramientas educativas incluidas'
    },
    'E': {
        'title': 'Conectividad',
        'subtitle': 'WiFi y Bluetooth',
        'text': 'Listo para conectar y aprender'
    },
    'F': {
        'title': 'Multimedia',
        'subtitle': 'Audio y Video',
        'text': 'Experimenta y crea contenido'
    },
    'G': {
        'title': 'Comunidad',
        'subtitle': 'computadorita.cr',
        'text': 'Únete a nuestra comunidad'
    }
}

def backup_original_images():
    """Backup original Raspberry Pi images"""
    print("📦 Backing up original images...")
    BACKUP_DIR.mkdir(exist_ok=True)

    # Backup OS icon
    if OS_ICON_PNG.exists():
        import shutil
        shutil.copy2(OS_ICON_PNG, BACKUP_DIR / "OS.png.original")
        print(f"  ✓ Backed up OS.png")

    # Backup marketing slides
    if MARKETING_DIR.exists():
        for slide in MARKETING_DIR.glob("*.png"):
            import shutil
            shutil.copy2(slide, BACKUP_DIR / f"{slide.name}.original")
        print(f"  ✓ Backed up {len(list(MARKETING_DIR.glob('*.png')))} marketing slides")

    print(f"  Backups saved to: {BACKUP_DIR}")

def create_os_icon():
    """Convert CRIcon.svg to OS.png (40x40 for NOOBS)"""
    print("\n🎨 Creating OS icon...")

    if not CR_ICON_SVG.exists():
        print(f"  ✗ ERROR: {CR_ICON_SVG} not found")
        return False

    try:
        # Convert SVG to PNG at higher resolution for better quality
        png_data = cairosvg.svg2png(
            url=str(CR_ICON_SVG),
            output_width=80,
            output_height=80
        )

        # Load with PIL and resize to 40x40 with antialiasing
        from io import BytesIO
        img = Image.open(BytesIO(png_data))
        img = img.resize((40, 40), Image.Resampling.LANCZOS)

        # Save
        img.save(OS_ICON_PNG, "PNG", optimize=True)
        print(f"  ✓ Created OS.png (40x40)")
        return True

    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        return False

def create_marketing_slide(letter, title, subtitle, text):
    """Create a marketing slide with Computado Rita branding"""
    print(f"  Creating slide {letter}.png...")

    # VGA resolution
    width, height = 640, 480

    # Create base image with gradient background
    img = Image.new('RGB', (width, height), color='#1a1a2e')
    draw = ImageDraw.Draw(img)

    # Add gradient effect (simple two-color gradient)
    for y in range(height):
        r = int(26 + (16 * y / height))
        g = int(26 + (42 * y / height))
        b = int(46 + (90 * y / height))
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Add icon in top corner
    if CR_ICON_SVG.exists():
        try:
            icon_data = cairosvg.svg2png(
                url=str(CR_ICON_SVG),
                output_width=80,
                output_height=80
            )
            from io import BytesIO
            icon = Image.open(BytesIO(icon_data))
            icon = icon.convert("RGBA")
            img.paste(icon, (20, 20), icon)
        except:
            pass

    # Add text
    try:
        # Try to use a nice font
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 48)
        subtitle_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 32)
        text_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()

    # Center text positioning
    title_y = 150
    subtitle_y = 220
    text_y = 300

    # Draw title
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text(((width - title_width) // 2, title_y), title, fill='#ffffff', font=title_font)

    # Draw subtitle
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    draw.text(((width - subtitle_width) // 2, subtitle_y), subtitle, fill='#00d4ff', font=subtitle_font)

    # Draw text
    text_bbox = draw.textbbox((0, 0), text, font=text_font)
    text_width = text_bbox[2] - text_bbox[0]
    draw.text(((width - text_width) // 2, text_y), text, fill='#cccccc', font=text_font)

    # Add footer
    footer_text = "Computado Rita OS • @computadorita.cr"
    footer_bbox = draw.textbbox((0, 0), footer_text, font=text_font)
    footer_width = footer_bbox[2] - footer_bbox[0]
    draw.text(((width - footer_width) // 2, height - 50), footer_text, fill='#666666', font=text_font)

    # Save
    output_file = MARKETING_DIR / f"{letter}.png"
    img.save(output_file, "PNG", optimize=True)

    return True

def create_all_marketing_slides():
    """Create all 7 marketing slides"""
    print("\n🖼️  Creating marketing slides...")

    MARKETING_DIR.mkdir(parents=True, exist_ok=True)

    for letter, content in SLIDE_MESSAGES.items():
        try:
            create_marketing_slide(
                letter,
                content['title'],
                content['subtitle'],
                content['text']
            )
        except Exception as e:
            print(f"  ✗ ERROR creating slide {letter}: {e}")
            return False

    print(f"  ✓ Created all 7 marketing slides")
    return True

def main():
    print("=" * 60)
    print("Computado Rita Image Branding Script")
    print("=" * 60)

    # Check if SVG files exist
    if not CR_ICON_SVG.exists():
        print(f"✗ ERROR: {CR_ICON_SVG} not found")
        return 1

    # Backup originals
    backup_original_images()

    # Create OS icon
    if not create_os_icon():
        print("\n✗ Failed to create OS icon")
        return 1

    # Create marketing slides
    if not create_all_marketing_slides():
        print("\n✗ Failed to create marketing slides")
        return 1

    print("\n" + "=" * 60)
    print("✓ SUCCESS: All images created!")
    print("=" * 60)
    print(f"\nImages created:")
    print(f"  • OS Icon: {OS_ICON_PNG}")
    print(f"  • Marketing Slides: {MARKETING_DIR}/*.png")
    print(f"\nOriginal images backed up to: {BACKUP_DIR}")
    print("\nNext steps:")
    print("  1. Review the generated images")
    print("  2. Run ./build.sh or ./build-docker.sh to build your image")
    print("  3. Your NOOBS installer will now show Computado Rita branding!")

    return 0

if __name__ == "__main__":
    sys.exit(main())
