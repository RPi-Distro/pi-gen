# Jambox

**A Raspberry Pi micro-SD card image for online jamming.  
Runs Jamulus (client-server), SonoBus (peer-to-peer), JamTaba (NINJAM) or QJackTrip on Raspberry Pi, with web browser UI.  
Pre-built image file is available under "Releases" to download and burn with balenaEtcher**

 * Makes it easy for non-technical musicians to play together online, with a high-quality, high-performnace, low-cost system.
 * Suitable for a musical group or school to supply a pre-configured jamming appliance.

### Features
 * Runs on a **headless Raspberry Pi**.  Pi4 is highly recommended but Jambox has been verified to work on Pi3B.
 * **easy UI access via web browser** on same local network.
 * Wired ethernet connection required (wireless adds jitter).
 * Audio interface required (USB or HAT card).
 * Can be easily configured to automatically connect to a Jamulus server on startup, then shutdown after a time (i.e. 2 hours).
 * Real-time kernel (on Pi4, low-latency kernel on Pi3) and default settings for low delay.
 * Jamulus requires a Jamulus server, in same area for lowest delay. Use a public server, or host your own. 
 * Can run as a Jamulus Server.
 * SonoBus for peer-to-peer jamming.
 * JamTaba for long-distance jamming using NINJAM servers.
 * QJackTrip for multi-machine network jamming.
 * Jamming apps can be updated via desktop "Update Apps" button.
 * HDMI monitor can be used if desired.

---
<img src="https://jambox-project.s3-us-west-2.amazonaws.com/resources/jambox_desktop_13-shadow.png" width="871" />

<img src="https://jambox-project.s3-us-west-2.amazonaws.com/resources/jambox_screen1-shadow.png" width="871" />

---
### Easy to Setup
 1. Download image file from "Releases" (https://github.com/kdoren/jambox-pi-gen/releases).  No need to unzip.
 2. Flash micro SD card using balenaEtcher.
 3. (optional) customize settings after burning by editing/adding files in /boot/payload directory.
 4. Works with most USB audio interfaces and audio HAT cards.  Some interfaces may require changes to settings files.
 5. Connect wires: ethernet, USB audio interface, mic/instrument, headphones and power.
 6. Headphone amp may be needed (i.e. Rockville RHPA-4) if audio interface can't drive your headphones loud enough.

### Easy to Use
 1. Power on, boot up.
 2. Raspberry Pi will acquire a local IP address and register its access URL with urlrelay.com
 3. From any web browser on same local network (i.e. laptop or tablet), access Raspberry Pi UI via urlrelay.com/go
 4. Web browser will show Raspberry Pi desktop.
 5. Jamulus will automatically launch at startup.
 6. If JAMULUS_SERVER was configured, Jamulus will automatically connect (and shutdown after JAMULUS_TIMEOUT minutes)
 7. Double-click on a jamming app desktop icon:
   -- "Jamulus Start" to launch Jamulus.
   -- "SonoBus Start" to launch SonoBus.
   -- "JamTaba Start" to launch JamTaba.
   -- "QJackTrip Start" to launch QJackTrip.
 8. Double-click on desktop icon "Off Switch" to shut down Raspberry Pi.

---
### Simple hardware platform
Raspberry Pi + Audio Interface.  Can be attached to a board with velcro and pre-wired.

**Suggested Bill of Materials**, prices in USD as of Mar 2, 2021:

|Price (USD)|Item|URL|
|-----:|--|--|
|$ 35|Raspberry Pi 4-2GB|https://vilros.com/products/raspberry-pi-4-2gb-ram|
|14|Vilros Self Cooling Heavy Duty Case|https://vilros.com/products/vilros-raspberry-pi-4-compatible-self-cooling-heavy-duty-aluminum-case|
|11|Vilros Power Supply with Switch|https://vilros.com/products/vilros-usb-c-5v-3a-power-supply-with-switch-designed-for-pi-4|
|7|SanDisk Ultra 16GB micro SD card|https://www.amazon.com/gp/product/9966573445|
|45|Behringer UM2 USB Audio Interface|https://www.americanmusical.com/behringer-u-phoria-um2-usb-audio-interface/p/BEH-UM2|
|15|Pyle PDMIC78 Microphone|https://www.amazon.com/gp/product/B005BSOVRY|
|8|XLR Microphone Cable, 10 ft|https://www.amazon.com/gp/product/B07D5CPNWY|
|22|Microphone Stand w/clip|https://www.amazon.com/gp/product/B00OZ9C9LK|
|?|Over-ear Headphones|Use decent ones (likely $40 or more)|

---
### Customizable Settings
* Can be set immediately after flashing, on micro SD card "boot" partition /payload directory
* Or set later after booting
* Depending on your interface, you may be able to lower delay by reducing NPERIODS in /etc/jackdrc.conf.
* if JAMULUS_SERVER is defined, Jambox will automatically connect on boot, then power off after 2 hours.
* AJ_SNAPSHOT files are stored in /home/pi/.config/aj_snapshot/

| Name | Value | Default | File |
|----------|----------------------------------------|--------------------------------------|---------|
| **urlrelay settings** ||||
| NODE_ID | *id unique for your local network* | 1 | /etc/urlrelay/urlrelay.conf |
| URL_ARGS | *url arguments sent to noVNC* | /?password=jambox | /etc/urlrelay/urlrelay.conf |
| **Jamulus Settings** ||||
| JAMULUS_AUTOSTART | *set to 1 to launch on boot* | 0 | /home/pi/.config/Jamulus/jamulus_start.conf |
| JAMULUS_SERVER | *DNS name or IP of Jamulus server* | | /home/pi/.config/Jamulus/jamulus_start.conf |
| JAMULUS_TIMEOUT | *shutdown timer if auto-connecting* | 120m | /home/pi/.config/Jamulus/jamulus_start.conf |
| AJ_SNAPSHOT | *filename of alsa-jack patch configuration* | ajs-jamulus-stereo.xml | /home/pi/.config/Jamulus/jamulus_start.conf |
| MASTER_LEVEL | *master output level for USB interface* | 80% | /home/pi/.config/Jamulus/jamulus_start.conf |
| CAPTURE_LEVEL | *capture level for USB interface* | 80% | /home/pi/.config/Jamulus/jamulus_start.conf |
| **SonoBus Settings** ||||
| SONOBUS_AUTOSTART | *set to 1 to launch on boot* | 0 | /home/pi/.config/sonobus_start.conf |
| AJ_SNAPSHOT | *filename of alsa-jack patch configuration* | ajs-sonobus-stereo.xml | /home/pi/.config/sonobus_start.conf |
| MASTER_LEVEL | *master output level for USB interface* | 80% | /home/pi/.config/sonobus_start.conf |
| CAPTURE_LEVEL | *capture level for USB interface* | 80% | /home/pi/.config/sonobus_start.conf |
| **Jack Settings** ||||
| DEVICE | *alsa device ID of USB interface* | last capture device | /etc/jackdrc.conf |
| PERIOD | *Jack Audio samples per period* | 64 [pi4] or 128 [pi3]| /etc/jackdrc.conf |
| NPERIODS | *Jack Audio number of periods per buffer* | 8 [pi4] or 4 [pi3]| /etc/jackdrc.conf |
| **Jamulus Server Settings** | *see file* || /home/pi/.config/Jamulus/jamulus-server.conf |

---
### Web Browser access to Raspberry Pi Desktop - How it works
**urlrelay + noVNC = easy web browser access to Raspberry Pi desktop, without installing anything or knowing its IP address**

##### urlrelay
 1. Raspberry PI on wired ethernet gets private IP address on local network assigned by router (DHCP), but we don't know what it is.
 2. urlrelay service running on Raspberry Pi registers its private IP access URL with urlrelay.com (web service in AWS)
 3. urlrelay.com stores this URL using source IP (public IP of router) as primary key
 4. urlrelay.com uses NODE_ID (default: "1") as secondary key
 5. If only a single device is registered for a local network (source IP), NODE_ID doesn't matter.  From web browser on same local network (same source IP), urlrelay.com/go will redirect to Raspberry Pi.
 6. If >1 device exists on same local network, NODE_ID of each device should be different, then access via urlrelay.com/go?id=<NODE_ID>
 7. Recommended practice is to assign a different id to each micro SD card after flashing (i.e. NODE_ID=11), and place a label on each box with full URL "urlrelay.com/go?id=11"
 8. urlrelay.com deletes stale registrations after a set time (currently 30 days)

##### noVNC
 1. Web browser on same local network gets URL as a redirect from urlrelay.com
 2. noVNC is a VNC client written in Javascript which runs in web browser
 3. noVNC js code is served to browser from Raspberry Pi by a mini-http server on port 6080
 4. noVNC running in browser makes websocket connection to Rasbpberry Pi 
 5. websockify (companion to noVNC) bridges websocket to VNC server
 6. Raspberry Pi runs VNC server presenting linux desktop


**Original pi-gen README.md follows:**

---
# pi-gen

Tool used to create Raspberry Pi OS images. (Previously known as Raspbian).


## Dependencies

pi-gen runs on Debian-based operating systems. Currently it is only supported on
either Debian Buster or Ubuntu Xenial and is known to have issues building on
earlier releases of these systems. On other Linux distributions it may be possible
to use the Docker build described below.

To install the required dependencies for `pi-gen` you should run:

```bash
apt-get install coreutils quilt parted qemu-user-static debootstrap zerofree zip \
dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl bc
```

The file `depends` contains a list of tools needed.  The format of this
package is `<tool>[:<debian-package>]`.


## Config

Upon execution, `build.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables.

The following environment variables are supported:

 * `IMG_NAME` **required** (Default: unset)

   The name of the image to build with the current stage directories.  Setting
   `IMG_NAME=Raspbian` is logical for an unmodified RPi-Distro/pi-gen build,
   but you should use something else for a customized version.  Export files
   in stages may add suffixes to `IMG_NAME`.

 * `RELEASE` (Default: buster)

   The release version to build images against. Valid values are jessie, stretch
   buster, bullseye, and testing.

 * `APT_PROXY` (Default: unset)

   If you require the use of an apt proxy, set it here.  This proxy setting
   will not be included in the image, making it safe to use an `apt-cacher` or
   similar package for development.

   If you have Docker installed, you can set up a local apt caching proxy to
   like speed up subsequent builds like this:

       docker-compose up -d
       echo 'APT_PROXY=http://172.17.0.1:3142' >> config

 * `BASE_DIR`  (Default: location of `build.sh`)

   **CAUTION**: Currently, changing this value will probably break build.sh

   Top-level directory for `pi-gen`.  Contains stage directories, build
   scripts, and by default both work and deployment directories.

 * `WORK_DIR`  (Default: `"$BASE_DIR/work"`)

   Directory in which `pi-gen` builds the target system.  This value can be
   changed if you have a suitably large, fast storage location for stages to
   be built and cached.  Note, `WORK_DIR` stores a complete copy of the target
   system for each build stage, amounting to tens of gigabytes in the case of
   Raspbian.

   **CAUTION**: If your working directory is on an NTFS partition you probably won't be able to build: make sure this is a proper Linux filesystem.

 * `DEPLOY_DIR`  (Default: `"$BASE_DIR/deploy"`)

   Output directory for target system images and NOOBS bundles.

 * `DEPLOY_ZIP` (Default: `1`)

   Setting to `0` will deploy the actual image (`.img`) instead of a zipped image (`.zip`).

 * `USE_QEMU` (Default: `"0"`)

   Setting to '1' enables the QEMU mode - creating an image that can be mounted via QEMU for an emulated
   environment. These images include "-qemu" in the image file name.

 * `LOCALE_DEFAULT` (Default: "en_GB.UTF-8" )

   Default system locale.

 * `TARGET_HOSTNAME` (Default: "raspberrypi" )

   Setting the hostname to the specified value.

 * `KEYBOARD_KEYMAP` (Default: "gb" )

   Default keyboard keymap.

   To get the current value from a running system, run `debconf-show
   keyboard-configuration` and look at the
   `keyboard-configuration/xkb-keymap` value.

 * `KEYBOARD_LAYOUT` (Default: "English (UK)" )

   Default keyboard layout.

   To get the current value from a running system, run `debconf-show
   keyboard-configuration` and look at the
   `keyboard-configuration/variant` value.

 * `TIMEZONE_DEFAULT` (Default: "Europe/London" )

   Default keyboard layout.

   To get the current value from a running system, look in
   `/etc/timezone`.

 * `FIRST_USER_NAME` (Default: "pi" )

   Username for the first user

 * `FIRST_USER_PASS` (Default: "raspberry")

   Password for the first user

 * `WPA_ESSID`, `WPA_PASSWORD` and `WPA_COUNTRY` (Default: unset)

   If these are set, they are use to configure `wpa_supplicant.conf`, so that the Raspberry Pi can automatically connect to a wireless network on first boot. If `WPA_ESSID` is set and `WPA_PASSWORD` is unset an unprotected wireless network will be configured. If set, `WPA_PASSWORD` must be between 8 and 63 characters.

 * `ENABLE_SSH` (Default: `0`)

   Setting to `1` will enable ssh server for remote log in. Note that if you are using a common password such as the defaults there is a high risk of attackers taking over you Raspberry Pi.

  * `PUBKEY_SSH_FIRST_USER` (Default: unset)

   Setting this to a value will make that value the contents of the FIRST_USER_NAME's ~/.ssh/authorized_keys.  Obviously the value should
   therefore be a valid authorized_keys file.  Note that this does not
   automatically enable SSH.

  * `PUBKEY_ONLY_SSH` (Default: `0`)

   * Setting to `1` will disable password authentication for SSH and enable
   public key authentication.  Note that if SSH is not enabled this will take
   effect when SSH becomes enabled.

 * `STAGE_LIST` (Default: `stage*`)

    If set, then instead of working through the numeric stages in order, this list will be followed. For example setting to `"stage0 stage1 mystage stage2"` will run the contents of `mystage` before stage2. Note that quotes are needed around the list. An absolute or relative path can be given for stages outside the pi-gen directory.

A simple example for building Raspbian:

```bash
IMG_NAME='Raspbian'
```

The config file can also be specified on the command line as an argument the `build.sh` or `build-docker.sh` scripts.

```
./build.sh -c myconfig
```

This is parsed after `config` so can be used to override values set there.

## How the build process works

The following process is followed to build images:

 * Loop through all of the stage directories in alphanumeric order

 * Move on to the next directory if this stage directory contains a file called
   "SKIP"

 * Run the script ```prerun.sh``` which is generally just used to copy the build
   directory between stages.

 * In each stage directory loop through each subdirectory and then run each of the
   install scripts it contains, again in alphanumeric order. These need to be named
   with a two digit padded number at the beginning.
   There are a number of different files and directories which can be used to
   control different parts of the build process:

     - **00-run.sh** - A unix shell script. Needs to be made executable for it to run.

     - **00-run-chroot.sh** - A unix shell script which will be run in the chroot
       of the image build directory. Needs to be made executable for it to run.

     - **00-debconf** - Contents of this file are passed to debconf-set-selections
       to configure things like locale, etc.

     - **00-packages** - A list of packages to install. Can have more than one, space
       separated, per line.

     - **00-packages-nr** - As 00-packages, except these will be installed using
       the ```--no-install-recommends -y``` parameters to apt-get.

     - **00-patches** - A directory containing patch files to be applied, using quilt.
       If a file named 'EDIT' is present in the directory, the build process will
       be interrupted with a bash session, allowing an opportunity to create/revise
       the patches.

  * If the stage directory contains files called "EXPORT_NOOBS" or "EXPORT_IMAGE" then
    add this stage to a list of images to generate

  * Generate the images for any stages that have specified them

It is recommended to examine build.sh for finer details.


## Docker Build

Docker can be used to perform the build inside a container. This partially isolates
the build from the host system, and allows using the script on non-debian based
systems (e.g. Fedora Linux). The isolate is not complete due to the need to use
some kernel level services for arm emulation (binfmt) and loop devices (losetup).

To build:

```bash
vi config         # Edit your config file. See above.
./build-docker.sh
```

If everything goes well, your finished image will be in the `deploy/` folder.
You can then remove the build container with `docker rm -v pigen_work`

If something breaks along the line, you can edit the corresponding scripts, and
continue:

```bash
CONTINUE=1 ./build-docker.sh
```

To examine the container after a failure you can enter a shell within it using:

```bash
sudo docker run -it --privileged --volumes-from=pigen_work pi-gen /bin/bash
```

After successful build, the build container is by default removed. This may be undesired when making incremental changes to a customized build. To prevent the build script from remove the container add

```bash
PRESERVE_CONTAINER=1 ./build-docker.sh
```

There is a possibility that even when running from a docker container, the
installation of `qemu-user-static` will silently fail when building the image
because `binfmt-support` _must be enabled on the underlying kernel_. An easy
fix is to ensure `binfmt-support` is installed on the host machine before
starting the `./build-docker.sh` script (or using your own docker build
solution).


## Stage Anatomy

### Raspbian Stage Overview

The build of Raspbian is divided up into several stages for logical clarity
and modularity.  This causes some initial complexity, but it simplifies
maintenance and allows for more easy customization.

 - **Stage 0** - bootstrap.  The primary purpose of this stage is to create a
   usable filesystem.  This is accomplished largely through the use of
   `debootstrap`, which creates a minimal filesystem suitable for use as a
   base.tgz on Debian systems.  This stage also configures apt settings and
   installs `raspberrypi-bootloader` which is missed by debootstrap.  The
   minimal core is installed but not configured, and the system will not quite
   boot yet.

 - **Stage 1** - truly minimal system.  This stage makes the system bootable by
   installing system files like `/etc/fstab`, configures the bootloader, makes
   the network operable, and installs packages like raspi-config.  At this
   stage the system should boot to a local console from which you have the
   means to perform basic tasks needed to configure and install the system.
   This is as minimal as a system can possibly get, and its arguably not
   really usable yet in a traditional sense yet.  Still, if you want minimal,
   this is minimal and the rest you could reasonably do yourself as sysadmin.

 - **Stage 2** - lite system.  This stage produces the Raspbian-Lite image.  It
   installs some optimized memory functions, sets timezone and charmap
   defaults, installs fake-hwclock and ntp, wireless LAN and bluetooth support,
   dphys-swapfile, and other basics for managing the hardware.  It also
   creates necessary groups and gives the pi user access to sudo and the
   standard console hardware permission groups.

   There are a few tools that may not make a whole lot of sense here for
   development purposes on a minimal system such as basic Python and Lua
   packages as well as the `build-essential` package.  They are lumped right
   in with more essential packages presently, though they need not be with
   pi-gen.  These are understandable for Raspbian's target audience, but if
   you were looking for something between truly minimal and Raspbian-Lite,
   here's where you start trimming.

 - **Stage 3** - desktop system.  Here's where you get the full desktop system
   with X11 and LXDE, web browsers, git for development, Raspbian custom UI
   enhancements, etc.  This is a base desktop system, with some development
   tools installed.

 - **Stage 4** - Normal Raspbian image. System meant to fit on a 4GB card. This is the
   stage that installs most things that make Raspbian friendly to new
   users like system documentation.

 - **Stage 5** - The Raspbian Full image. More development
   tools, an email client, learning tools like Scratch, specialized packages
   like sonic-pi, office productivity, etc.  

### Stage specification

If you wish to build up to a specified stage (such as building up to stage 2
for a lite system), place an empty file named `SKIP` in each of the `./stage`
directories you wish not to include.

Then add an empty file named `SKIP_IMAGES` to `./stage4` and `./stage5` (if building up to stage 2) or
to `./stage2` (if building a minimal system).

```bash
# Example for building a lite system
echo "IMG_NAME='Raspbian'" > config
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES
sudo ./build.sh  # or ./build-docker.sh
```

If you wish to build further configurations upon (for example) the lite
system, you can also delete the contents of `./stage3` and `./stage4` and
replace with your own contents in the same format.


## Skipping stages to speed up development

If you're working on a specific stage the recommended development process is as
follows:

 * Add a file called SKIP_IMAGES into the directories containing EXPORT_* files
   (currently stage2, stage4 and stage5)
 * Add SKIP files to the stages you don't want to build. For example, if you're
   basing your image on the lite image you would add these to stages 3, 4 and 5.
 * Run build.sh to build all stages
 * Add SKIP files to the earlier successfully built stages
 * Modify the last stage
 * Rebuild just the last stage using ```sudo CLEAN=1 ./build.sh```
 * Once you're happy with the image you can remove the SKIP_IMAGES files and
   export your image to test

# Troubleshooting

## `64 Bit Systems`
Please note there is currently an issue when compiling with a 64 Bit OS. See https://github.com/RPi-Distro/pi-gen/issues/271

## `binfmt_misc`

Linux is able execute binaries from other architectures, meaning that it should be
possible to make use of `pi-gen` on an x86_64 system, even though it will be running
ARM binaries. This requires support from the [`binfmt_misc`](https://en.wikipedia.org/wiki/Binfmt_misc)
kernel module.

You may see the following error:

```
update-binfmts: warning: Couldn't load the binfmt_misc module.
```

To resolve this, ensure that the following files are available (install them if necessary):

```
/lib/modules/$(uname -r)/kernel/fs/binfmt_misc.ko
/usr/bin/qemu-arm-static
```

You may also need to load the module by hand - run `modprobe binfmt_misc`.
