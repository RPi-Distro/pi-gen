# Raspberry Pi Text Replacement Guide

This document lists every location where "Raspberry Pi" (case-insensitive, with or without spaces) appears in the codebase and indicates whether it can be safely replaced with "Computado Rita".

**Note**: Current config already sets: `TARGET_HOSTNAME="computadorita"` and `PI_GEN_RELEASE="CROS"`

---

## ✅ SAFE TO REPLACE - Configuration & User-Visible Text

These locations contain user-visible text that should be replaced for custom branding.

### 1. Build Configuration - `build.sh`

#### Line 178: PI_GEN_RELEASE Variable
```bash
export PI_GEN_RELEASE=${PI_GEN_RELEASE:-Raspberry Pi reference}
```
**Current**: Default is "Raspberry Pi reference"
**Replacement**: ALREADY SET in config as "CROS"
**Status**: ✅ Already customized in `/home/svvs/pi-gen/config`

#### Line 205: TARGET_HOSTNAME Variable
```bash
export TARGET_HOSTNAME=${TARGET_HOSTNAME:-raspberrypi}
```
**Current**: Default hostname is "raspberrypi"
**Replacement**: ALREADY SET in config as "computadorita"
**Status**: ✅ Already customized in `/home/svvs/pi-gen/config`

#### Line 268: Error Message
```bash
echo "On Raspberry Pi OS (64-bit), you can switch to a suitable kernel by adding the following to /boot/firmware/config.txt and rebooting:"
```
**Replacement**: Replace "Raspberry Pi OS" with "Computado Rita OS"
**Action**: Edit this error message in `build.sh:268`

---

### 2. Cloud-Init Configuration

#### `stage2/04-cloud-init/files/user-data` - Line 25
```yaml
#hostname: raspberrypi
```
**Current**: Commented default hostname
**Replacement**: Change to `#hostname: computadorita` (or leave as-is since it's commented)
**Status**: ✅ Optional - it's already commented out, TARGET_HOSTNAME will be used

#### `stage2/04-cloud-init/files/99_raspberry-pi.cfg` - Filename
**Current**: File named `99_raspberry-pi.cfg`
**Replacement**: Rename to `99_computado-rita.cfg`
**Action Required**:
1. Rename file: `mv stage2/04-cloud-init/files/99_raspberry-pi.cfg stage2/04-cloud-init/files/99_computado-rita.cfg`
2. Update install script at `stage2/04-cloud-init/01-run.sh:8`:
   ```bash
   # Change from:
   install -v -D -m 644 -t "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/" files/99_raspberry-pi.cfg
   # To:
   install -v -D -m 644 -t "${ROOTFS_DIR}/etc/cloud/cloud.cfg.d/" files/99_computado-rita.cfg
   ```

---

### 3. NOOBS Configuration

#### `export-noobs/00-release/files/os.json`

**Line 5**: Default password (uses "raspberry" as password)
```json
"password": "raspberry",
```
**Current**: Default password is "raspberry"
**Replacement**: You may want to change this, but NOT to "Computado Rita" - choose a different default password
**Status**: ⚠️ SECURITY - Change to a different password or remove

**Line 14**: URL
```json
"url": "http://www.raspbian.org/",
```
**Current**: Points to raspbian.org
**Replacement**: Change to your project URL
**Status**: ✅ Replace with your URL

**Line 15**: Username
```json
"username": "pi",
```
**Current**: Default username is "pi"
**Note**: This will be renamed on first boot unless DISABLE_FIRST_BOOT_USER_RENAME=1
**Status**: ℹ️ Controlled by FIRST_USER_NAME config variable

---

### 4. Documentation Files (Safe to Replace)

#### `stage2/03-accept-mathematica-eula/00-debconf` - Line 1
```
# Do you accept the Wolfram - Raspberry Pi® Bundle License Agreement?
```
**Current**: Comment refers to "Raspberry Pi® Bundle"
**Replacement**: Change to "Computado Rita Bundle" (remove ®)
**Status**: ✅ Safe to replace in comment

---

## ⚠️ REPLACE WITH CAUTION - Package Names

These are Debian package names from Raspberry Pi repositories. Replacing text here won't change the actual packages installed.

### Package Files That Reference Raspberry Pi

**DO NOT modify package names themselves** - they must match actual Debian package names. These are listed for information only:

#### `stage0/00-configure-apt/01-packages`
- `raspberrypi-archive-keyring` - ❌ DO NOT CHANGE (package name)

#### `stage2/01-sys-tweaks/00-packages`
- `raspberrypi-sys-mods` - ❌ DO NOT CHANGE (package name)
- `raspberrypi-net-mods` - ❌ DO NOT CHANGE (package name)
- `python3-rpi-lgpio` - ❌ DO NOT CHANGE (package name)
- `rpi-swap` - ❌ DO NOT CHANGE (package name)
- `rpi-loop-utils` - ❌ DO NOT CHANGE (package name)
- `rpi-update` - ❌ DO NOT CHANGE (package name)
- `rpi-eeprom` - ❌ DO NOT CHANGE (package name)
- `rpi-keyboard-config` - ❌ DO NOT CHANGE (package name)
- `rpi-keyboard-fw-update` - ❌ DO NOT CHANGE (package name)
- `rpi-usb-gadget` - ❌ DO NOT CHANGE (package name)
- `rpi-connect-lite` - ❌ DO NOT CHANGE (package name)

#### `stage1/03-install-packages/00-packages`
- `raspi-config` - ❌ DO NOT CHANGE (package name)
- `raspi-utils` - ❌ DO NOT CHANGE (package name)

#### `stage0/02-firmware/01-packages`
- `raspi-firmware` - ❌ DO NOT CHANGE (package name)
- `linux-image-rpi-v8` - ❌ DO NOT CHANGE (package name)
- `linux-image-rpi-2712` - ❌ DO NOT CHANGE (package name)
- `linux-headers-rpi-v8` - ❌ DO NOT CHANGE (package name)
- `linux-headers-rpi-2712` - ❌ DO NOT CHANGE (package name)

---

## ❌ DO NOT REPLACE - Technical References

These are technical file paths, URLs, or system references that must remain unchanged.

### 1. Repository URLs - `stage0/00-configure-apt/files/raspi.sources`
```
URIs: http://archive.raspberrypi.com/debian/
Signed-By: /usr/share/keyrings/raspberrypi-archive-keyring.pgp
```
**Status**: ❌ DO NOT CHANGE - This is the official Raspberry Pi package repository URL

### 2. Keyring Files
- `/stage0/00-configure-apt/files/raspberrypi-archive-keyring.pgp` - ❌ DO NOT RENAME
- `/stage0/files/raspberrypi.gpg` - ❌ DO NOT RENAME
- Install path in `stage0/00-configure-apt/00-run.sh:23`:
  ```bash
  install -m 644 files/raspberrypi-archive-keyring.pgp "${ROOTFS_DIR}/usr/share/keyrings/"
  ```
  **Status**: ❌ DO NOT CHANGE - System expects this exact path

### 3. GitHub URLs - `export-image/05-finalise/01-run.sh`

Lines 75-84: These URLs fetch firmware and kernel information:
```bash
"$ROOTFS_DIR/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz"
"https://github.com/raspberrypi/firmware/tree/%s"
"https://github.com/raspberrypi/firmware/raw/$firmware/extra/git_hash"
"https://github.com/raspberrypi/linux/tree/%s"
"https://github.com/raspberrypi/firmware/raw/$firmware/extra/uname_string7"
```
**Status**: ❌ DO NOT CHANGE - Official Raspberry Pi Foundation GitHub repositories

### 4. System Documentation Path - `export-noobs/prerun.sh`
```bash
"${STAGE_WORK_DIR}/rootfs/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz"
```
**Status**: ❌ DO NOT CHANGE - Installed by raspberrypi-kernel package

### 5. Comment References to Package Behavior

#### `stage2/02-net-tweaks/01-run.sh:3`
```bash
# Newer versions of raspberrypi-sys-mods set rfkill.default_state=0 to prevent
```
**Status**: ℹ️ Optional - This is just a comment explaining package behavior

---

## 📋 SUMMARY TABLE

| Location | Line | Current Text | Can Replace? | Replacement |
|----------|------|--------------|--------------|-------------|
| `build.sh` | 178 | `Raspberry Pi reference` | ✅ Yes | Already set to "CROS" in config |
| `build.sh` | 205 | `raspberrypi` (hostname) | ✅ Yes | Already set to "computadorita" in config |
| `build.sh` | 268 | `Raspberry Pi OS` | ✅ Yes | "Computado Rita OS" |
| `stage2/04-cloud-init/files/99_raspberry-pi.cfg` | filename | `raspberry-pi` | ✅ Yes | Rename to `99_computado-rita.cfg` |
| `stage2/04-cloud-init/01-run.sh` | 8 | `99_raspberry-pi.cfg` | ✅ Yes | Update to `99_computado-rita.cfg` |
| `stage2/04-cloud-init/files/user-data` | 25 | `raspberrypi` | ✅ Yes | "computadorita" (optional, commented) |
| `export-noobs/00-release/files/os.json` | 5 | `raspberry` (password) | ⚠️ Caution | Choose different password |
| `export-noobs/00-release/files/os.json` | 14 | `raspbian.org` | ✅ Yes | Your project URL |
| `stage2/03-accept-mathematica-eula/00-debconf` | 1 | `Raspberry Pi®` | ✅ Yes | "Computado Rita" |
| Package names (all) | - | `raspberrypi-*`, `rpi-*`, `raspi-*` | ❌ No | Must keep exact package names |
| `raspi.sources` | 2,5 | `raspberrypi.com`, keyring path | ❌ No | Required repository URL |
| GitHub URLs | - | `github.com/raspberrypi/*` | ❌ No | Official repositories |
| Documentation paths | - | `/usr/share/doc/raspberrypi-*` | ❌ No | Installed by packages |

---

## 🎯 ACTION CHECKLIST

To rebrand from "Raspberry Pi" to "Computado Rita":

### Already Done ✅
- [x] Set `PI_GEN_RELEASE="CROS"` in config
- [x] Set `TARGET_HOSTNAME="computadorita"` in config

### To Do 📝

1. **Edit `build.sh:268`**
   - Change error message from "Raspberry Pi OS" to "Computado Rita OS"

2. **Rename cloud-init config file**
   ```bash
   mv stage2/04-cloud-init/files/99_raspberry-pi.cfg stage2/04-cloud-init/files/99_computado-rita.cfg
   ```

3. **Update cloud-init install script**
   - Edit `stage2/04-cloud-init/01-run.sh:8`
   - Change filename reference from `99_raspberry-pi.cfg` to `99_computado-rita.cfg`

4. **Update NOOBS configuration** (if using NOOBS)
   - Edit `export-noobs/00-release/files/os.json:14`
   - Change URL from `http://www.raspbian.org/` to your project URL

5. **Optional: Update Mathematica EULA comment**
   - Edit `stage2/03-accept-mathematica-eula/00-debconf:1`
   - Change comment from "Raspberry Pi®" to "Computado Rita"

6. **Security: Change default password** (if using NOOBS)
   - Edit `export-noobs/00-release/files/os.json:5`
   - Change from `"raspberry"` to a secure default or remove

### Do NOT Change ⛔
- Package names in `*-packages*` files
- Repository URLs in `raspi.sources`
- GitHub URLs in scripts
- Keyring file names
- System documentation paths

---

## 📝 NOTES

1. **Package Dependencies**: All `raspberrypi-*`, `rpi-*`, and `raspi-*` packages come from the official Raspberry Pi repository and cannot be renamed. They will still reference "Raspberry Pi" internally.

2. **Configuration Override**: The `config` file already overrides the most visible "Raspberry Pi" references (release name and hostname).

3. **Deep Branding**: For complete rebranding, you would need to:
   - Fork and modify the `rpd-theme` package (desktop theme)
   - Create custom versions of system packages
   - Set up your own package repository
   - This is beyond simple text replacement

4. **License**: The `LICENSE` file contains "Copyright (c) 2015 Raspberry Pi (Trading) Ltd." - This should NOT be changed as it's the original copyright holder.

5. **Documentation Files**: Release notes and README files contain many "Raspberry Pi" references but are excluded from this analysis as they are documentation/changelog files.
