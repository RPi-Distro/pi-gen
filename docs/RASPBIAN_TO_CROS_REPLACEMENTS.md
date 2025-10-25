# Raspbian/RaspiOS to CROS Replacement Summary

This document details all replacements made to change "Raspbian", "RaspbianOS", and "RaspiOS" references to "CROS" throughout the codebase.

**Replacement Date**: October 25, 2025
**Project**: Computado Rita OS (CROS)
**Contact**: @computadorita.cr

---

## 🔄 Replacements Made

### 1. Build Script Default Image Name

**File**: `build.sh:182`

**Before**:
```bash
export IMG_NAME="${IMG_NAME:-raspios-$RELEASE-$ARCH}"
```

**After**:
```bash
export IMG_NAME="${IMG_NAME:-cros-$RELEASE-$ARCH}"
```

**Impact**:
- Default image name changed from `raspios-trixie-arm64` to `cros-trixie-arm64`
- Output files will be named `CROS-YYYY-MM-DD-arm64.img.xz` (since IMG_NAME is overridden in config)
- Work directory default changes from `work/raspios-*` to `work/cros-*`

**Capitalization Pattern**: `raspios` → `cros` (all lowercase)

---

### 2. Dependency Check Error Message

**File**: `scripts/dependencies_check:26`

**Before**:
```bash
echo "This can be resolved on Debian/Raspbian systems by installing:"
```

**After**:
```bash
echo "This can be resolved on Debian/CROS systems by installing:"
```

**Impact**:
- Error message now references "Debian/CROS systems" when dependencies are missing
- This message appears when building on a system without required dependencies

**Capitalization Pattern**: `Raspbian` → `CROS` (first letter capitalized)

**Note**: This refers to the system you're building ON (the host system), not the system being built. If you're building CROS on a Debian or Ubuntu system, this message might be slightly confusing since you're not actually on a "CROS system" yet. Consider changing to just "Debian-based systems" if preferred.

---

### 3. README Documentation Examples

**File**: `README.md:231`

**Before**:
```bash
A simple example for building Raspberry Pi OS:

IMG_NAME='raspios'
```

**After**:
```bash
A simple example for building Computado Rita OS:

IMG_NAME='cros'
```

**Impact**: Documentation now shows CROS examples instead of RaspiOS

**Capitalization Pattern**: `raspios` → `cros` (all lowercase)

---

**File**: `README.md:58`

**Before**:
```
* `IMG_NAME` (Default: `raspios-$RELEASE-$ARCH`, for example: `raspios-trixie-armhf`)
```

**After**:
```
* `IMG_NAME` (Default: `cros-$RELEASE-$ARCH`, for example: `cros-trixie-armhf`)
```

**Impact**: Documentation reflects new default image naming

**Capitalization Pattern**: `raspios` → `cros` (all lowercase, appears twice)

---

**File**: `README.md:392`

**Before**:
```bash
# Example for building a lite system
echo "IMG_NAME='raspios'" > config
```

**After**:
```bash
# Example for building a lite system
echo "IMG_NAME='cros'" > config
```

**Impact**: Build examples updated to use CROS naming

**Capitalization Pattern**: `raspios` → `cros` (all lowercase)

---

### 4. CLAUDE.md AI Assistant Documentation

**File**: `CLAUDE.md:95`

**Before**:
```
- `IMG_NAME`: Root name of the OS image (default: raspios-$RELEASE-$ARCH)
```

**After**:
```
- `IMG_NAME`: Root name of the OS image (default: cros-$RELEASE-$ARCH)
```

**Impact**: AI assistant documentation now reflects CROS defaults

**Capitalization Pattern**: `raspios` → `cros` (all lowercase)

---

## 📝 NOT Changed (Historical/Reference Data)

### Release Notes Historical Reference

**File**: `export-noobs/00-release/files/release_notes.txt:838`

**Content**:
```
* Based on Raspbian Stretch (Debian version 9)
```

**Status**: ⚠️ NOT CHANGED

**Reason**: This is a historical changelog entry documenting what older versions were based on. Changing historical facts in changelogs is generally not recommended. This entry refers to legacy releases from 2017-2018 and is kept for historical accuracy.

**If you want to change this**: Replace "Raspbian Stretch" with "CROS Stretch"

---

## 📊 Summary Statistics

| Location | Type | Count | Capitalization |
|----------|------|-------|----------------|
| Code (build.sh) | Default value | 1 | `raspios` → `cros` |
| Code (dependencies_check) | Error message | 1 | `Raspbian` → `CROS` |
| Documentation (README.md) | Examples | 4 | `raspios` → `cros` |
| Documentation (CLAUDE.md) | Reference | 1 | `raspios` → `cros` |
| **Total Changed** | | **7** | |
| Historical (release_notes.txt) | Changelog | 1 | Not changed |

---

## 🎯 Capitalization Patterns Applied

As requested, capitalization was preserved based on the original:

1. **All lowercase**: `raspios` → `cros`
2. **First letter capitalized**: `Raspbian` → `CROS`
3. **Pattern maintained**: If original was `RaspbianOS`, it would become `CROS` (maintaining caps)

---

## ✅ Verification

To verify all changes were made correctly:

```bash
# Search for remaining "raspios" references (should only find .md files or comments)
grep -r "raspios" /home/svvs/pi-gen --exclude-dir=.git --exclude-dir=work --exclude-dir=deploy -i

# Search for "raspbian" references (should only find release_notes.txt)
grep -r "raspbian" /home/svvs/pi-gen --exclude-dir=.git --exclude-dir=work --exclude-dir=deploy -i
```

**Expected Results**:
- No `raspios` references in non-.md files except your config overrides
- Only 1 `raspbian` reference in `release_notes.txt` (historical)

---

## 🔗 Related Changes

These replacements complement the earlier rebranding changes:

### Already Completed (See [REBRANDING_CHANGES.md](REBRANDING_CHANGES.md))
- ✅ "Raspberry Pi" → "Computado Rita" in error messages
- ✅ "Raspberry Pi OS" → "Computado Rita OS" in build.sh
- ✅ Cloud-init config renamed: `99_raspberry-pi.cfg` → `99_computado-rita.cfg`
- ✅ NOOBS URL: `raspbian.org` → `computadorita.cr`
- ✅ Config header with @computadorita.cr contact

### Combined Result
Your build now produces:
- **Image name**: `CROS-2025-10-25-arm64.img.xz` (from config IMG_NAME="CROS")
- **OS Name**: CROS
- **Release**: CROS
- **Hostname**: computadorita
- **Default fallback**: `cros-$RELEASE-$ARCH` (if IMG_NAME not set in config)

---

## 🚀 Impact on Build Output

### Before Changes
```
work/raspios-trixie-arm64/
deploy/2025-10-25-raspios-trixie-arm64.img.xz
```

### After Changes (with your config)
```
work/CROS/
deploy/CROS-2025-10-25-arm64.img.xz
```

### If Building Without Custom Config
```
work/cros-trixie-arm64/
deploy/2025-10-25-cros-trixie-arm64.img.xz
```

---

## 📚 Complete Rebranding Checklist

- [x] Replace "Raspberry Pi" text → "Computado Rita"
- [x] Replace "raspios" → "cros"
- [x] Replace "Raspbian" → "CROS"
- [x] Update NOOBS configuration
- [x] Update cloud-init files
- [x] Update documentation (README, CLAUDE.md)
- [x] Add contact information (@computadorita.cr)
- [ ] Replace visual assets (images, logos)
- [ ] Replace desktop theme (rpd-* packages)
- [ ] Test build completes successfully
- [ ] Test image boots on hardware

---

## 🔍 Additional Search Terms

If you need to find any remaining references to the original OS names:

```bash
# Find all OS name variations
grep -r "rasp.*os\|raspbian\|raspios" . --exclude-dir=.git -i

# Find package references (these cannot be changed)
grep -r "raspberrypi-\|rpi-\|raspi-" . --exclude-dir=.git --include="*-packages*"

# Find URL references
grep -r "raspberrypi\.com\|raspbian\.org" . --exclude-dir=.git -i
```

---

## ⚠️ Important Notes

1. **Package Names**: Cannot be changed - `raspberrypi-*`, `rpi-*`, `raspi-*` packages must retain their original names as they come from official Raspberry Pi repositories.

2. **Repository URLs**: Cannot be changed - `http://archive.raspberrypi.com/debian/` must remain to access Pi-specific packages.

3. **System Paths**: Installed by packages, cannot be changed in the build scripts.

4. **Backward Compatibility**: These changes do not break compatibility with Raspberry Pi hardware. Your CROS image will still run on Raspberry Pi boards.

5. **Build System**: The underlying pi-gen build system remains unchanged, only branding and naming are modified.

---

**Document Version**: 1.0
**Last Updated**: October 25, 2025
**Maintained by**: Computado Rita Project (@computadorita.cr)
