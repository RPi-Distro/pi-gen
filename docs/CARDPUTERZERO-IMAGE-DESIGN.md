# CardputerZero Image 定制设计

## 一、设备当前状态 (对比官方镜像)

### 自定义 config.txt 差异

官方 config.txt 无以下内容，CardputerZero 需要额外加：

```ini
dtparam=i2c_arm=on
dtparam=spi=on
dtoverlay=cardputerzero-overlay

# Force HDMI for fbcp (virtual 320x170 to match LCD)
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=320 170 60 1 0 0 0
```

### cmdline.txt 额外参数

```
quiet splash plymouth.ignore-serial-consoles cfg80211.ieee80211_regdom=AE
```

### modprobe 配置

```
/etc/modules-load.d/modules.conf:
  i2c-dev

/etc/modprobe.d/blacklist-8192cu.conf:
  blacklist 8192cu

/etc/modprobe.d/rfkill_default.conf:
  options rfkill default_state=0
```

### 自定义内核模块 (8个 .ko)

| 模块 | 源码目录 | 功能 |
|------|---------|------|
| st7789v_m5stack.ko | modules/st7789v-1.0/ | LCD 显示驱动 |
| pwm_bl_m5stack.ko | modules/st7789v-1.0/ | LCD 背光 PWM |
| tca8418_keypad_m5stack.ko | modules/tca8418-1.0/ | 键盘矩阵驱动 |
| es8389_m5stack.ko | modules/es8389-1.0/ | 音频 codec |
| bq27xxx_battery.ko | modules/bq27220-1.0/ | 电池监控 |
| bq27xxx_battery_i2c.ko | modules/bq27220-1.0/ | 电池 I2C 接口 |
| bq27xxx_battery_hdq.ko | modules/bq27220-1.0/ | 电池 HDQ 接口 |
| py32ioexp.ko | modules/py32ioexp-1.0/ | IO 扩展芯片 |

### 自定义 overlay (.dtbo)

| 文件 | 作用 |
|------|------|
| cardputerzero-overlay.dtbo | 主 overlay：ST7789V LCD + TCA8418 键盘 + ES8389 音频 + GPIO 配置 |

### APPLaunch 服务

- 包：`applaunch_0.2-m5stack1_arm64.deb`（33MB，来自 dianjixz/M5CardputerZero-UserDemo release）
- 服务：`APPLaunch.service`，`WantedBy=multi-user.target`，`Restart=always`
- 路径：`/usr/share/APPLaunch/bin/M5CardputerZero-APPLaunch`

---

## 二、pi-gen 定制方案设计

### 目录结构

```
pi-gen/
├── stage2/05-cardputerzero/
│   ├── 00-packages              ← 额外 apt 包
│   ├── 01-run.sh               ← 编译内核模块 + 安装 overlay
│   ├── files/
│   │   ├── config.txt.patch     ← config.txt 补丁
│   │   ├── cmdline.txt.patch    ← cmdline.txt 补丁
│   │   ├── modules-load.conf    ← /etc/modules-load.d/
│   │   └── modprobe/            ← /etc/modprobe.d/ 配置
│   └── 02-run.sh               ← 安装 APPLaunch deb + enable service
```

### 00-packages

```
fastfetch
cmatrix
i2c-tools
```

### 01-run.sh — 编译内核模块

```bash
#!/bin/bash -e

# 在 chroot 里安装编译依赖（构建完成后删除）
on_chroot << 'CHROOT'
apt-get install -y --no-install-recommends \
    build-essential \
    linux-headers-rpi-v8 \
    device-tree-compiler \
    git

# 克隆驱动源码
git clone --depth=1 https://github.com/m5stack/m5stack-linux-dtoverlays.git /tmp/dtoverlays

# 编译 st7789v + pwm_bl
cd /tmp/dtoverlays/modules/st7789v-1.0
make
make install

# 编译 tca8418 键盘
cd /tmp/dtoverlays/modules/tca8418-1.0
make
make install

# 编译 es8389 音频
cd /tmp/dtoverlays/modules/es8389-1.0
make
make install

# 编译 bq27220 电池
cd /tmp/dtoverlays/modules/bq27220-1.0
make
make install

# 编译 py32ioexp
cd /tmp/dtoverlays/modules/py32ioexp-1.0
make
make install

# 编译 overlay dtbo
cd /tmp/dtoverlays/modules/CardputerZero
make
cp *.dtbo /boot/firmware/overlays/

# depmod
depmod -a

# 清理编译依赖（减小镜像体积）
apt-get purge -y build-essential linux-headers-rpi-v8 device-tree-compiler git
apt-get autoremove -y
rm -rf /tmp/dtoverlays

CHROOT
```

### 02-run.sh — 安装 APPLaunch + 配置

```bash
#!/bin/bash -e

on_chroot << 'CHROOT'
# 下载最新 APPLaunch deb (匿名 curl 从 public repo release)
RELEASE_URL=$(curl -s https://api.github.com/repos/dianjixz/M5CardputerZero-UserDemo/releases/latest \
    | grep -o 'https://.*applaunch.*_arm64\.deb' | head -1)
curl -fsSL "$RELEASE_URL" -o /tmp/applaunch.deb
dpkg -i /tmp/applaunch.deb
rm /tmp/applaunch.deb

# Enable APPLaunch service
systemctl enable APPLaunch.service
CHROOT

# 追加 config.txt 自定义内容
cat >> "${ROOTFS_DIR}/boot/firmware/config.txt" << 'CONFIGTXT'

# CardputerZero customization
dtparam=i2c_arm=on
dtparam=spi=on
dtoverlay=cardputerzero-overlay
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=320 170 60 1 0 0 0
CONFIGTXT

# cmdline.txt 追加参数
sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles cfg80211.ieee80211_regdom=AE/' \
    "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

# modules-load
cat > "${ROOTFS_DIR}/etc/modules-load.d/cardputerzero.conf" << 'MODULES'
i2c-dev
MODULES

# modprobe configs
cat > "${ROOTFS_DIR}/etc/modprobe.d/blacklist-8192cu.conf" << 'MODPROBE'
blacklist 8192cu
MODPROBE

cat > "${ROOTFS_DIR}/etc/modprobe.d/rfkill_default.conf" << 'MODPROBE'
options rfkill default_state=0
MODPROBE
```

---

## 三、APPLaunch deb 获取方式

public 仓库的 release asset 可以匿名下载：

```bash
# 通过 GitHub API 获取最新 release 的 deb URL
curl -s https://api.github.com/repos/dianjixz/M5CardputerZero-UserDemo/releases \
    | grep -o 'https://github.com/.*/applaunch.*_arm64\.deb' | head -1

# 直接下载（不需要 token）
curl -fsSL -o applaunch.deb "URL_FROM_ABOVE"
```

APPLaunch 服务启动顺序：
- `WantedBy=multi-user.target` — 在基本系统启动后、用户登录前启动
- `Restart=always` + `RestartSec=1` — 崩溃后 1 秒重启
- 比桌面环境启动**更早**（multi-user 在 graphical 之前）

---

## 四、内核模块编译方式对比

| 方式 | 优点 | 缺点 |
|------|------|------|
| **chroot 里编译（推荐）** | 保证和目标内核版本匹配 | 需要装 headers，构建慢 +5min |
| DKMS 包 | 内核升级自动重编 | 需要在镜像里保留 headers（+150MB） |
| 预编译 .ko 上传 | 构建快 | 内核升级后模块失效 |

**推荐方式**：在 pi-gen chroot 里编译（01-run.sh），编译完删除 headers，不留垃圾。

---

## 五、设备额外软件包

设备上有 1723 个包（vs 官方 Desktop 1646 个），多出的主要是：
- CardputerZero demo apps（game-tetris, demo-matrix 等）— 通过 APPLaunch deb 仓库管理
- 开发工具（build-essential, cmake）— 可能不需要预装
- xserver/wayland 相关 — 来自官方 Desktop stage

---

## 六、CI/CD 流程

```
push to arm64 branch
    │
    ├─ Build Desktop (stage0-4 + stage2/05-cardputerzero)
    │   ├─ 安装 apt 包
    │   ├─ 克隆 m5stack-linux-dtoverlays，编译内核模块
    │   ├─ 安装 overlay dtbo
    │   ├─ 下载安装 APPLaunch deb
    │   ├─ 配置 config.txt / cmdline.txt / modprobe
    │   └─ 输出: YYYY-MM-DD-cardputerzero-trixie-arm64.img.xz
    │
    └─ Verify Lite (check only, no upload)
```

输出: prerelease with tag `YYYYMMDD-HHMMSS-<commit7>`
