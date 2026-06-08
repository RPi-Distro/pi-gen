#!/bin/bash
# Compare two Raspberry Pi OS images: partition layout, boot files, rootfs packages
# Usage: ./tools/compare-images.sh <our-image.img> <official-image.img>

set -euo pipefail

DEBUGFS=/opt/homebrew/Cellar/e2fsprogs/1.47.4/sbin/debugfs
DUMPE2FS=/opt/homebrew/Cellar/e2fsprogs/1.47.4/sbin/dumpe2fs

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <our-image.img> <official-image.img>"
    echo "  Supports .img, .img.xz, .zip files (auto-decompresses)"
    exit 1
fi

IMG_OURS="$1"
IMG_OFFICIAL="$2"
TMPDIR=$(mktemp -d /tmp/img-compare.XXXXXX)
trap "rm -rf $TMPDIR" EXIT

decompress() {
    local src="$1" dst="$2"
    if [[ "$src" == *.xz ]]; then
        echo "  Decompressing $src..."
        xz -dkc "$src" > "$dst"
    elif [[ "$src" == *.zip ]]; then
        echo "  Unzipping $src..."
        unzip -p "$src" "*.img" > "$dst"
    elif [[ "$src" == *.img ]]; then
        cp "$src" "$dst"
    else
        echo "Unknown format: $src"
        exit 1
    fi
}

echo "=========================================="
echo " Raspberry Pi Image Comparison Tool"
echo "=========================================="
echo ""
echo "Ours:     $IMG_OURS"
echo "Official: $IMG_OFFICIAL"
echo ""

# Decompress if needed
OURS="$TMPDIR/ours.img"
OFFICIAL="$TMPDIR/official.img"

echo "[1/7] Preparing images..."
decompress "$IMG_OURS" "$OURS"
decompress "$IMG_OFFICIAL" "$OFFICIAL"
echo ""

# File sizes
echo "[2/7] Image sizes"
echo "  Ours:     $(ls -lh "$OURS" | awk '{print $5}')"
echo "  Official: $(ls -lh "$OFFICIAL" | awk '{print $5}')"
OURS_SIZE=$(stat -f%z "$OURS")
OFFICIAL_SIZE=$(stat -f%z "$OFFICIAL")
if [[ "$OURS_SIZE" == "$OFFICIAL_SIZE" ]]; then
    echo "  ✓ Identical raw size"
else
    echo "  ✗ Different raw size (ours=$OURS_SIZE, official=$OFFICIAL_SIZE)"
fi
echo ""

# Partition layout
echo "[3/7] Partition layout"
get_partitions() {
    hdiutil imageinfo "$1" 2>/dev/null | grep -E "partition-start|partition-length|partition-hint|FAT|Ext" | sed 's/^[ \t]*//'
}
OURS_PARTS=$(get_partitions "$OURS")
OFFICIAL_PARTS=$(get_partitions "$OFFICIAL")
if [[ "$OURS_PARTS" == "$OFFICIAL_PARTS" ]]; then
    echo "  ✓ Partition layout identical"
else
    echo "  ✗ Partition layout differs:"
    diff <(echo "$OURS_PARTS") <(echo "$OFFICIAL_PARTS") || true
fi
echo ""

# Extract partition offsets (FAT32 boot)
BOOT_START=$(hdiutil imageinfo "$OURS" 2>/dev/null | grep -A1 "Windows_FAT_32" | grep "partition-start" | awk -F: '{print $2}' | tr -d ' ' | head -1)
BOOT_LEN=$(hdiutil imageinfo "$OURS" 2>/dev/null | grep -B1 "Windows_FAT_32" | grep "partition-length" | awk -F: '{print $2}' | tr -d ' ' | head -1)
ROOT_START=$(hdiutil imageinfo "$OURS" 2>/dev/null | grep -A1 "Linux_Ext2FS" | grep "partition-start" | awk -F: '{print $2}' | tr -d ' ' | head -1)
ROOT_LEN=$(hdiutil imageinfo "$OURS" 2>/dev/null | grep -B1 "Linux_Ext2FS" | grep "partition-length" | awk -F: '{print $2}' | tr -d ' ' | head -1)

# Mount boot partitions
echo "[4/7] Boot partition (FAT32) comparison"
OURS_DEV=$(hdiutil attach -nomount "$OURS" 2>/dev/null | grep "Windows_FAT_32" | awk '{print $1}')
OFFICIAL_DEV=$(hdiutil attach -nomount "$OFFICIAL" 2>/dev/null | grep "Windows_FAT_32" | awk '{print $1}')

mkdir -p "$TMPDIR/boot-ours" "$TMPDIR/boot-official"
mount -t msdos "$OURS_DEV" "$TMPDIR/boot-ours" 2>/dev/null
mount -t msdos "$OFFICIAL_DEV" "$TMPDIR/boot-official" 2>/dev/null

# Boot file list with sizes and hashes
echo "  Generating file lists and checksums..."
(cd "$TMPDIR/boot-ours" && find . -type f | sort | while read f; do
    sz=$(stat -f%z "$f")
    hash=$(shasum -a 256 "$f" | awk '{print $1}')
    printf "%s\t%s\t%s\n" "$f" "$sz" "$hash"
done) > "$TMPDIR/boot-ours.manifest"

(cd "$TMPDIR/boot-official" && find . -type f | sort | while read f; do
    sz=$(stat -f%z "$f")
    hash=$(shasum -a 256 "$f" | awk '{print $1}')
    printf "%s\t%s\t%s\n" "$f" "$sz" "$hash"
done) > "$TMPDIR/boot-official.manifest"

BOOT_OURS_COUNT=$(wc -l < "$TMPDIR/boot-ours.manifest")
BOOT_OFFICIAL_COUNT=$(wc -l < "$TMPDIR/boot-official.manifest")
echo "  Files: ours=$BOOT_OURS_COUNT, official=$BOOT_OFFICIAL_COUNT"

# Compare boot manifests
BOOT_DIFF=$(diff "$TMPDIR/boot-ours.manifest" "$TMPDIR/boot-official.manifest" || true)
if [[ -z "$BOOT_DIFF" ]]; then
    echo "  ✓ All boot files identical (content + hash)"
else
    BOOT_IDENTICAL=$(comm -12 <(cut -f1,3 "$TMPDIR/boot-ours.manifest" | sort) <(cut -f1,3 "$TMPDIR/boot-official.manifest" | sort) | wc -l)
    BOOT_DIFFER=$(comm -23 <(cut -f1,3 "$TMPDIR/boot-ours.manifest" | sort) <(cut -f1,3 "$TMPDIR/boot-official.manifest" | sort) | wc -l)
    echo "  Identical files: $BOOT_IDENTICAL"
    echo "  Different files: $BOOT_DIFFER"
    echo "  Files with different hash:"
    # Show files present in both but with different hash
    comm -12 <(cut -f1 "$TMPDIR/boot-ours.manifest" | sort) <(cut -f1 "$TMPDIR/boot-official.manifest" | sort) | while read f; do
        H1=$(grep "^${f}	" "$TMPDIR/boot-ours.manifest" | cut -f3)
        H2=$(grep "^${f}	" "$TMPDIR/boot-official.manifest" | cut -f3)
        if [[ "$H1" != "$H2" ]]; then
            S1=$(grep "^${f}	" "$TMPDIR/boot-ours.manifest" | cut -f2)
            S2=$(grep "^${f}	" "$TMPDIR/boot-official.manifest" | cut -f2)
            echo "    $f (ours: ${S1}B, official: ${S2}B)"
        fi
    done
    # Files only in one
    ONLY_OURS=$(comm -23 <(cut -f1 "$TMPDIR/boot-ours.manifest" | sort) <(cut -f1 "$TMPDIR/boot-official.manifest" | sort))
    ONLY_OFFICIAL=$(comm -13 <(cut -f1 "$TMPDIR/boot-ours.manifest" | sort) <(cut -f1 "$TMPDIR/boot-official.manifest" | sort))
    if [[ -n "$ONLY_OURS" ]]; then
        echo "  Only in ours:"
        echo "$ONLY_OURS" | sed 's/^/    /'
    fi
    if [[ -n "$ONLY_OFFICIAL" ]]; then
        echo "  Only in official:"
        echo "$ONLY_OFFICIAL" | sed 's/^/    /'
    fi
fi

# Kernel version
echo ""
echo "[5/7] Kernel files"
for k in kernel8.img kernel_2712.img; do
    S1=$(stat -f%z "$TMPDIR/boot-ours/$k" 2>/dev/null || echo "0")
    S2=$(stat -f%z "$TMPDIR/boot-official/$k" 2>/dev/null || echo "0")
    if [[ "$S1" == "$S2" ]]; then
        echo "  ✓ $k: ${S1} bytes (identical)"
    else
        echo "  ✗ $k: ours=${S1}, official=${S2}"
    fi
done

# Unmount boot
umount "$TMPDIR/boot-ours" 2>/dev/null || true
umount "$TMPDIR/boot-official" 2>/dev/null || true
hdiutil detach $(echo "$OURS_DEV" | sed 's/s[0-9]*$//') 2>/dev/null || true
hdiutil detach $(echo "$OFFICIAL_DEV" | sed 's/s[0-9]*$//') 2>/dev/null || true

# Extract ext4 rootfs
echo ""
echo "[6/7] Rootfs (ext4) comparison"
dd if="$OURS" of="$TMPDIR/ours-root.ext4" bs=512 skip="$ROOT_START" count="$ROOT_LEN" 2>/dev/null
dd if="$OFFICIAL" of="$TMPDIR/official-root.ext4" bs=512 skip="$ROOT_START" count="$ROOT_LEN" 2>/dev/null

echo "  Filesystem stats:"
OURS_BLOCKS=$($DUMPE2FS -h "$TMPDIR/ours-root.ext4" 2>/dev/null | grep "Block count" | awk '{print $3}')
OURS_FREE=$($DUMPE2FS -h "$TMPDIR/ours-root.ext4" 2>/dev/null | grep "Free blocks" | awk '{print $3}')
OFFICIAL_BLOCKS=$($DUMPE2FS -h "$TMPDIR/official-root.ext4" 2>/dev/null | grep "Block count" | awk '{print $3}')
OFFICIAL_FREE=$($DUMPE2FS -h "$TMPDIR/official-root.ext4" 2>/dev/null | grep "Free blocks" | awk '{print $3}')

OURS_USED=$((OURS_BLOCKS - OURS_FREE))
OFFICIAL_USED=$((OFFICIAL_BLOCKS - OFFICIAL_FREE))
OURS_USED_MB=$(( OURS_USED * 4 / 1024 ))
OFFICIAL_USED_MB=$(( OFFICIAL_USED * 4 / 1024 ))

echo "    Ours:     ${OURS_USED_MB} MB used (${OURS_USED}/${OURS_BLOCKS} blocks, ${OURS_FREE} free)"
echo "    Official: ${OFFICIAL_USED_MB} MB used (${OFFICIAL_USED}/${OFFICIAL_BLOCKS} blocks, ${OFFICIAL_FREE} free)"

# Package comparison
echo ""
echo "[7/7] Package comparison"
$DEBUGFS -R "cat var/lib/dpkg/status" "$TMPDIR/ours-root.ext4" 2>/dev/null | grep -E "^Package: |^Version: " | paste - - | sort > "$TMPDIR/ours-pkgs-full.txt"
$DEBUGFS -R "cat var/lib/dpkg/status" "$TMPDIR/official-root.ext4" 2>/dev/null | grep -E "^Package: |^Version: " | paste - - | sort > "$TMPDIR/official-pkgs-full.txt"

OURS_PKG_COUNT=$(wc -l < "$TMPDIR/ours-pkgs-full.txt")
OFFICIAL_PKG_COUNT=$(wc -l < "$TMPDIR/official-pkgs-full.txt")
echo "  Total packages: ours=$OURS_PKG_COUNT, official=$OFFICIAL_PKG_COUNT"

# Packages with identical versions
IDENTICAL_PKGS=$(comm -12 "$TMPDIR/ours-pkgs-full.txt" "$TMPDIR/official-pkgs-full.txt" | wc -l)
echo "  Identical (name+version): $IDENTICAL_PKGS"

# Only in ours
ONLY_IN_OURS=$(comm -23 <(cut -f1 "$TMPDIR/ours-pkgs-full.txt" | sort) <(cut -f1 "$TMPDIR/official-pkgs-full.txt" | sort))
if [[ -n "$ONLY_IN_OURS" ]]; then
    echo "  Only in ours ($(echo "$ONLY_IN_OURS" | wc -l | tr -d ' ') packages):"
    echo "$ONLY_IN_OURS" | sed 's/^/    /'
fi

# Only in official
ONLY_IN_OFFICIAL=$(comm -13 <(cut -f1 "$TMPDIR/ours-pkgs-full.txt" | sort) <(cut -f1 "$TMPDIR/official-pkgs-full.txt" | sort))
if [[ -n "$ONLY_IN_OFFICIAL" ]]; then
    echo "  Only in official ($(echo "$ONLY_IN_OFFICIAL" | wc -l | tr -d ' ') packages):"
    echo "$ONLY_IN_OFFICIAL" | sed 's/^/    /'
fi

# Different versions
echo "  Packages with different versions:"
comm -12 <(cut -f1 "$TMPDIR/ours-pkgs-full.txt" | sort) <(cut -f1 "$TMPDIR/official-pkgs-full.txt" | sort) | while read pkg; do
    V1=$(grep "^${pkg}	" "$TMPDIR/ours-pkgs-full.txt" | head -1)
    V2=$(grep "^${pkg}	" "$TMPDIR/official-pkgs-full.txt" | head -1)
    if [[ "$V1" != "$V2" ]]; then
        echo "    $V1"
        echo "    $V2"
        echo ""
    fi
done

echo ""
echo "=========================================="
echo " Comparison complete"
echo "=========================================="
