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
dosfstools libarchive-tools libcap2-bin grep rsync xz-utils file git curl bc \
qemu-utils kpartx gpg
```

The file `depends` contains a list of tools needed.  The format of this
package is `<tool>[:<debian-package>]`.

## Getting started with building your images

Getting started is as simple as cloning this repository on your build machine. You
can do so with:

```bash
git clone --depth 1 https://github.com/RPI-Distro/pi-gen.git
```

Using `--depth 1` with `git clone` will create a shallow clone, only containing
the latest revision of the repository. Do not do this on your development machine.

Also, be careful to clone the repository to a base path **NOT** containing spaces.
This configuration is not supported by debootstrap and will lead to `pi-gen` not
running.

After cloning the repository, you can move to the next step and start configuring
your build.

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

* `USE_QCOW2` **EXPERIMENTAL** (Default: `0` )

    Instead of using traditional way of building the rootfs of every stage in
    single subdirectories and copying over the previous one to the next one,
    qcow2 based virtual disks with backing images are used in every stage.
    This speeds up the build process and reduces overall space consumption
    significantly.

    <u>Additional optional parameters regarding qcow2 build:</u>

    * `BASE_QCOW2_SIZE` (Default: 12G)

        Size of the virtual qcow2 disk.
        Note: it will not actually use that much of space at once but defines the
        maximum size of the virtual disk. If you change the build process by adding
        a lot of bigger packages or additional build stages, it can be necessary to
        increase the value because the virtual disk can run out of space like a normal
        hard drive would.

    **CAUTION:**  Although the qcow2 build mechanism will run fine inside Docker, it can happen
    that the network block device is not disconnected correctly after the Docker process has
    ended abnormally. In that case see [Disconnect an image if something went wrong](#Disconnect-an-image-if-something-went-wrong)

* `RELEASE` (Default: bullseye)

   The release version to build images against. Valid values are jessie, stretch,
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

### Passing arguments to Docker

When the docker image is run various required command line arguments are provided.  For example the system mounts the `/dev` directory to the `/dev` directory within the docker container.  If other arguments are required they may be specified in the PIGEN_DOCKER_OPTS environment variable.  For example setting `PIGEN_DOCKER_OPTS="--add-host foo:192.168.0.23"` will add '192.168.0.23   foo' to the `/etc/hosts` file in the container.  The `--name`
and `--privileged` options are already set by the script and should not be redefined.

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

# Regarding Qcow2 image building

### Get infos about the image in use

If you issue the two commands shown in the example below in a second command shell while a build
is running you can find out, which network block device is currently being used and which qcow2 image
is bound to it.

Example:

```bash
root@build-machine:~/$ lsblk | grep nbd
nbd1      43:32   0    10G  0 disk
├─nbd1p1  43:33   0    10G  0 part
└─nbd1p1 253:0    0    10G  0 part

root@build-machine:~/$ ps xa | grep qemu-nbd
 2392 pts/6    S+     0:00 grep --color=auto qemu-nbd
31294 ?        Ssl    0:12 qemu-nbd --discard=unmap -c /dev/nbd1 image-stage4.qcow2
```

Here you can see, that the qcow2 image `image-stage4.qcow2` is currently connected to `/dev/nbd1` with
the associated partition map `/dev/mapper/nbd1p1`. Don't worry that `lsblk` shows two entries. It is totally fine, because the device map is accessible via `/dev/mapper/nbd1p1` and also via `/dev/dm-0`. This is all part of the device mapper functionality of the kernel. See `dmsetup` for further information.

### Mount a qcow2 image

If you want to examine the content of a a single stage, you can simply mount the qcow2 image found in the `WORK_DIR` directory with the tool `./imagetool.sh`.

See `./imagetool.sh -h` for further details on how to use it.

### Disconnect an image if something went wrong

It can happen, that your build stops in case of an error. Normally `./build.sh` should handle image disconnection appropriately, but in rare cases, especially during a Docker build, this may not work as expected. If that happens, starting a new build will fail and you may have to disconnect the image and/or device yourself.

A typical message indicating that there are some orphaned device mapper entries is this:

```
Failed to set NBD socket
Disconnect client, due to: Unexpected end-of-file before all bytes were read
```

If that happens go through the following steps:

1. First, check if the image is somehow mounted to a directory entry and umount it as you would any other block device, like i.e. a hard disk or USB stick.

2. Second, to disconnect an image from `qemu-nbd`, the QEMU Disk Network Block Device Server, issue the following command (be sure to change the device name to the one actually used):

   ```bash
   sudo qemu-nbd -d /dev/nbd1
   ```

   Note: if you use Docker build, normally no active `qemu-nbd` process exists anymore as it will be terminated when the Docker container stops.

3. To disconnect a device partition map from the network block device, execute:

   ```bash
   sudo kpartx -d /dev/nbd1
   or
   sudo ./imagetool.sh --cleanup
   ```

   Note: The `imagetool.sh` command will cleanup any /dev/nbdX that is not connected to a running `qemu-nbd` daemon. Be careful if you use network block devices for other tasks utilizing NBDs on your build machine as well.

Now you should be able to start a new build without running into troubles again. Most of the time, especially when using Docker build, you will only need no. 3 to get everything up and running again.

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
