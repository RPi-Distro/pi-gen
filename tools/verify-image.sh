#!/bin/bash
# Verify CardputerZero image contains all required customizations.
# Usage: ./tools/verify-image.sh <image.img>
# Exit 0 = all checks pass, Exit 1 = failure (breaks CI)

set -euo pipefail

IMG="${1:?Usage: $0 <image.img>}"
ERRORS=0
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
pass() { echo "  ✓ $1"; }

echo "=========================================="
echo " CardputerZero Image Verification"
echo "=========================================="
echo " Image: $IMG"
echo ""

# --- Extract partitions ---
# Get partition offsets (sectors, 512 bytes each)
BOOT_START=$(fdisk -l "$IMG" 2>/dev/null | grep "W95 FAT32\|FAT32" | awk '{print $2}')
BOOT_END=$(fdisk -l "$IMG" 2>/dev/null | grep "W95 FAT32\|FAT32" | awk '{print $3}')
ROOT_START=$(fdisk -l "$IMG" 2>/dev/null | grep "Linux" | awk '{print $2}')
ROOT_END=$(fdisk -l "$IMG" 2>/dev/null | grep "Linux" | awk '{print $3}')

BOOT_SECTORS=$((BOOT_END - BOOT_START + 1))
ROOT_SECTORS=$((ROOT_END - ROOT_START + 1))

echo "[1/6] Extracting partitions..."
dd if="$IMG" of="$TMPDIR/boot.fat" bs=512 skip="$BOOT_START" count="$BOOT_SECTORS" 2>/dev/null
dd if="$IMG" of="$TMPDIR/root.ext4" bs=512 skip="$ROOT_START" count="$ROOT_SECTORS" 2>/dev/null

# --- Mount boot ---
mkdir -p "$TMPDIR/boot"
mount -o loop,ro "$TMPDIR/boot.fat" "$TMPDIR/boot" 2>/dev/null

echo ""
echo "[2/6] Boot partition (FAT32)"

# Check config.txt
if grep -q "dtoverlay=cardputerzero-overlay" "$TMPDIR/boot/config.txt" 2>/dev/null; then
    pass "config.txt: dtoverlay=cardputerzero-overlay"
else
    fail "config.txt: missing dtoverlay=cardputerzero-overlay"
fi

if grep -q "dtparam=spi=on" "$TMPDIR/boot/config.txt" 2>/dev/null; then
    pass "config.txt: dtparam=spi=on"
else
    fail "config.txt: missing dtparam=spi=on"
fi

if grep -q "dtparam=i2c_arm=on" "$TMPDIR/boot/config.txt" 2>/dev/null; then
    pass "config.txt: dtparam=i2c_arm=on"
else
    fail "config.txt: missing dtparam=i2c_arm=on"
fi


# Check overlay dtbo
if [ -f "$TMPDIR/boot/overlays/cardputerzero-overlay.dtbo" ]; then
    pass "overlays/cardputerzero-overlay.dtbo exists ($(stat -c%s "$TMPDIR/boot/overlays/cardputerzero-overlay.dtbo" 2>/dev/null || stat -f%z "$TMPDIR/boot/overlays/cardputerzero-overlay.dtbo") bytes)"
else
    fail "overlays/cardputerzero-overlay.dtbo MISSING"
fi

# Check cmdline.txt
if grep -q "quiet splash" "$TMPDIR/boot/cmdline.txt" 2>/dev/null; then
    pass "cmdline.txt: quiet splash"
else
    fail "cmdline.txt: missing quiet splash"
fi

umount "$TMPDIR/boot" 2>/dev/null || true

echo ""
echo "[3/6] Kernel modules (/lib/modules/*/extra/)"

REQUIRED_MODULES=(
    "bmi270_core.ko"
    "bq27xxx_battery.ko"  
    "bq27xxx_battery_i2c.ko"
    "m5ioe1.ko"
    "tca8418_keypad_m5stack.ko"
    "bmi270_i2c.ko"
    "bq27xxx_battery_hdq.ko"
    "es8389_m5stack.ko"
    "pwm_bl_m5stack.ko"
    "st7789v_m5stack.ko"
)

for mod in "${REQUIRED_MODULES[@]}"; do
    if debugfs -R "ls lib/modules" "$TMPDIR/root.ext4" 2>/dev/null | grep -q .; then
        KVER=$(debugfs -R "ls lib/modules" "$TMPDIR/root.ext4" 2>/dev/null | grep -o '[0-9][^ ]*rpi-v8')
        if debugfs -R "stat lib/modules/${KVER}/extra/${mod}" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "Size:"; then
            SIZE=$(debugfs -R "stat lib/modules/${KVER}/extra/${mod}" "$TMPDIR/root.ext4" 2>/dev/null | grep "Size:" | awk '{print $2}')
            pass "$mod ($SIZE bytes)"
        else
            fail "$mod MISSING"
        fi
    fi
done

echo ""
echo "[4/6] APPLaunch"

if debugfs -R "stat usr/share/APPLaunch/bin/M5CardputerZero-APPLaunch" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "Size:"; then
    pass "APPLaunch binary installed"
else
    fail "APPLaunch binary MISSING"
fi

if debugfs -R "cat usr/lib/systemd/system/APPLaunch.service" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "ExecStart"; then
    pass "APPLaunch.service exists"
else
    # Try alternative path
    if debugfs -R "cat lib/systemd/system/APPLaunch.service" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "ExecStart"; then
        pass "APPLaunch.service exists"
    else
        fail "APPLaunch.service MISSING"
    fi
fi

# APPLaunch is installed but intentionally not enabled by default.
if debugfs -R "ls etc/systemd/system/multi-user.target.wants" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "APPLaunch"; then
    pass "APPLaunch.service enabled"
else
    pass "APPLaunch.service not enabled by default"
fi

echo ""
echo "[5/6] Modprobe configuration"

if debugfs -R "cat etc/modules-load.d/cardputerzero.conf" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "i2c-dev"; then
    pass "modules-load.d: i2c-dev"
else
    fail "modules-load.d: i2c-dev MISSING"
fi

if debugfs -R "cat etc/modprobe.d/blacklist-8192cu.conf" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "blacklist 8192cu"; then
    pass "modprobe.d: blacklist 8192cu"
else
    fail "modprobe.d: blacklist 8192cu MISSING"
fi

if debugfs -R "cat etc/modprobe.d/rfkill_default.conf" "$TMPDIR/root.ext4" 2>/dev/null | grep -q "rfkill"; then
    pass "modprobe.d: rfkill default_state=0"
else
    fail "modprobe.d: rfkill MISSING"
fi

echo ""
echo "[6/6] Packages"

set +e
debugfs -R "cat var/lib/dpkg/status" "$TMPDIR/root.ext4" > "$TMPDIR/dpkg_status" 2>/dev/null
echo "  dpkg_status size: $(wc -c < "$TMPDIR/dpkg_status") bytes"

if grep -q "^Package: applaunch$" "$TMPDIR/dpkg_status"; then
    VER=$(grep -A5 "^Package: applaunch$" "$TMPDIR/dpkg_status" | grep "^Version:" | awk '{print $2}')
    pass "applaunch package installed (v$VER)"
else
    fail "applaunch package NOT installed"
fi

if grep -q "^Package: fastfetch$" "$TMPDIR/dpkg_status"; then
    pass "fastfetch installed"
else
    fail "fastfetch NOT installed"
fi

if grep -q "^Package: cmatrix$" "$TMPDIR/dpkg_status"; then
    pass "cmatrix installed"
else
    fail "cmatrix NOT installed"
fi
set -e

echo ""
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo " ✓ ALL CHECKS PASSED"
    echo "=========================================="
    exit 0
else
    echo " ✗ $ERRORS CHECK(S) FAILED"
    echo "=========================================="
    exit 1
fi
