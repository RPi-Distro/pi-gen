# Root Partition Resize 问题调研 (2026-06-08)

## 问题现象

使用 M5 Imager 烧录 CardputerZero OS 镜像后，首次启动时：
- ✅ 用户名/密码创建正常 (cloud-init cc_users)
- ✅ SSH host keys 生成正常 (cloud-init cc_ssh)
- ✅ WiFi 配置正常 (cloud-init network-config)
- ❌ Root 分区无法扩展到 SD 卡全容量

## 根本原因

**CardputerZero 的 U-Boot 不加载 initramfs。**

U-Boot BOOTCOMMAND:
```
show_logo; fatload mmc 0:1 ${kernel_addr_r} kernel8.img; booti ${kernel_addr_r} - ${gpu_fdt_addr}
```

`booti` 中间的 `-` 表示没有 initrd/initramfs。

### RPi OS 正常的 resize 流程（需要 initramfs）

1. **initramfs `local-premount/resize_early`**: 检查 cmdline 中的 `resize` 参数，执行 `parted resizepart` 扩展分区表（此时 rootfs 未 mount）
2. **initramfs `local-bottom/set_partuuid`**: 随机化 Disk ID，更新 fstab，从 cmdline.txt 删除 `resize`
3. **systemd `rpi-resize.service`** (ConditionFirstBoot=yes): Wants `systemd-growfs-root.service` 执行 `resize2fs`

由于 U-Boot 跳过了 initramfs，步骤 1 和 2 从未执行。

### 为什么 username/password/SSH 不受影响？

这些功能由 **cloud-init** 提供，作为 systemd service 在 PID1 启动后执行，完全不依赖 initramfs。

### 受影响的 initramfs 脚本

| 脚本 | 阶段 | 功能 | 影响 |
|------|------|------|------|
| `resize_early` | local-premount | `parted resizepart` | 分区无法扩展 |
| `set_partuuid` | local-bottom | 随机化 Disk ID + 清理 cmdline | Disk ID 不变，`resize` 参数残留 |
| `imager_fixup` | local-bottom | 修复 firstrun.sh 路径 | 对 cloudinit-rpi 无影响 |
| `rpi_wd` | init-top | watchdog | 可能影响硬件看门狗 |

## 排除的可能性

1. **M5 Imager 代码问题** — 排除。m5stack-imager 和官方 rpi-imager 的 `_customizeImage()` 逻辑完全一致，都只操作 FAT boot 分区，不碰 ext4 rootfs。
2. **machine-id 问题** — 排除。systemd PID1 在 `main()` 最早期读取 `/etc/machine-id`，"uninitialized" → `first_boot=true` 正常工作（SSH keys 正常证明了这一点）。
3. **cloud-init 干扰** — 排除。cloud-init 在 PID1 之后运行，不影响 ConditionFirstBoot 判断。

## systemd ConditionFirstBoot 机制（源码确认）

来源: `systemd/src/core/main.c:2497-2529`

```c
// PID1 在 main() 最早期，所有 service/generator 之前：
r = read_one_line_file("/etc/machine-id", &id_text);
if (r < 0 || streq(id_text, "uninitialized")) {
    first_boot = true;
    log_info("Detected first boot.");
}
```

Per-unit 检查 (`src/shared/condition.c:963`):
```c
static bool in_first_boot(void) {
    // 检查 /run/systemd/first-boot 文件是否存在
    r = RET_NERRNO(access("/run/systemd/first-boot", F_OK));
    return r >= 0;
}
```

## 修复方案

采用 systemd oneshot service 方案（不修改 U-Boot）：
- 在首次启动时执行 `parted resizepart` + `resize2fs`
- ext4 支持在线 resize，无需 reboot
- 使用 `ConditionFirstBoot=yes` 确保只执行一次
- service 执行后自动 disable 自身

## 参考

- raspberrypi-sys-mods: `initramfs-tools/scripts/local-premount/resize_early`
- raspberrypi-sys-mods: `debian/raspberrypi-sys-mods.rpi-resize.service`
- systemd source: `src/core/main.c`, `src/shared/machine-id-setup.c`, `src/shared/condition.c`
- U-Boot defconfig: `configs/cardputerzero_defconfig` → `CONFIG_BOOTCOMMAND`
