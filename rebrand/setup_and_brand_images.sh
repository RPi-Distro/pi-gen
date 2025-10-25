#!/bin/bash
#
# Computado Rita Image Branding Setup Script
#
# This script installs dependencies and runs the image branding script
# to replace all Raspberry Pi images with Computado Rita branding.
#

set -e

echo "=========================================="
echo "Computado Rita Image Branding Setup"
echo "=========================================="
echo

# Check if we're in the right directory
if [ ! -f "create_branded_images.py" ]; then
    echo "ERROR: This script must be run from the pi-gen directory"
    exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is required but not installed"
    echo "Please install Python 3: sudo apt-get install python3"
    exit 1
fi

echo "📦 Installing required Python packages..."
echo

# Install pip if not present
if ! command -v pip3 &> /dev/null; then
    echo "Installing pip..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
fi

# Install required Python packages
echo "Installing cairosvg and pillow..."
pip3 install --user cairosvg pillow

echo
echo "✓ Dependencies installed"
echo

# Run the branding script
echo "🎨 Running image branding script..."
echo
python3 create_branded_images.py

# Check exit code
if [ $? -eq 0 ]; then
    echo
    echo "=========================================="
    echo "✓ SUCCESS!"
    echo "=========================================="
    echo
    echo "All Raspberry Pi images have been replaced with"
    echo "Computado Rita branding!"
    echo
    echo "Original images backed up to: original_images_backup/"
    echo
    echo "Next steps:"
    echo "  1. Review images in export-noobs/00-release/files/"
    echo "  2. Build your image: ./build.sh or ./build-docker.sh"
    echo
else
    echo
    echo "=========================================="
    echo "✗ ERROR"
    echo "=========================================="
    echo
    echo "Image branding failed. Check the error messages above."
    exit 1
fi
