# Fix: Root Partition Not Expanding on First Boot

## Symptom

After flashing a CardputerZero OS image to a 64GB SD card, the root partition
stays at ~29GB instead of expanding to fill the entire card. Users must manually
run `raspi-config --expand-rootfs` or `growpart` + `resize2fs`.

## Root Cause

`/etc/machine-id` in the exported image contained the string `"uninitialized\n"`
(14 bytes) instead of being an **empty file (0 bytes)**.

systemd's `ConditionFirstBoot=yes` (used by `rpi-resize.service`) checks whether
`/etc/machine-id` is empty or missing. Any non-empty content — including the
literal word "uninitialized" — makes systemd consider the system as already
initialized, so it **skips all firstboot-only services**.

`rpi-resize.service` triggers `systemd-growfs-root.service`, which expands the
root partition and filesystem to fill the disk. With `ConditionFirstBoot=no`,
this never runs.

## How It Was Verified (on device pi@192.168.110.135)

```
$ stat /etc/machine-id
  Birth: 2026-04-13 08:15:40   ← created during pi-gen build, not first boot

$ systemctl show rpi-resize.service | grep Condition
  ConditionResult=no            ← firstboot condition NOT met

$ systemctl is-enabled rpi-resize
  disabled                      ← service disabled itself (it ran the ExecStartPost
                                   disable, but the actual growfs never fired because
                                   ConditionFirstBoot was false)

$ journalctl -u rpi-resize
  -- No entries --              ← never executed

$ journalctl -u systemd-growfs-root
  -- No entries --              ← never executed

$ cloud-init log: no growpart records (cloud.cfg modules list doesn't include it)
```

## Comparison with Official RPi OS pi-gen

| | Official (RPi-Distro/pi-gen bookworm) | CardputerZero fork (before fix) |
|---|---|---|
| Line in `export-image/05-finalise/01-run.sh` | `true > "${ROOTFS_DIR}/etc/machine-id"` | `echo "uninitialized" > "${ROOTFS_DIR}/etc/machine-id"` |
| Result | Empty file (0 bytes) → firstboot=yes | 14-byte string → firstboot=no |
| Partition expansion | Works ✅ | Broken ❌ |

## Fix

```diff
-echo "uninitialized" > "${ROOTFS_DIR}/etc/machine-id"
+true > "${ROOTFS_DIR}/etc/machine-id"
```

## Expansion Chain (when working correctly)

1. First boot: systemd sees empty `/etc/machine-id` → generates new ID → marks
   `ConditionFirstBoot=yes`
2. `rpi-resize.service` fires (oneshot, `Wants=systemd-growfs-root.service`)
3. `systemd-growfs-root.service` runs `/usr/lib/systemd/systemd-growfs /`
4. On systemd v254+ (Trixie ships v256), `systemd-growfs` handles MBR partition
   expansion (growpart equivalent) + resize2fs in one step
5. Root partition fills the entire SD card
6. `rpi-resize.service` disables itself (`ExecStartPost=systemctl disable %n`)

## Why 29.2GB (not 6GB)

The 29.2GB figure equals the `ROOT_PART_SIZE` calculated by `export-image/prerun.sh`:

```
ROOT_PART_SIZE = (ROOT_SIZE * 1.2 + 200MB)
```

Where `ROOT_SIZE` is the `du` of the rootfs at export time (including
linux-headers, build-essential, and other packages installed during the build).
The partition in the .img file is fixed at this size; only firstboot expansion
grows it to match the physical media.
