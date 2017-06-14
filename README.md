# Dependencies

sudo apt-get update && sudo apt-get install git quilt kpartx realpath qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin -y && cd ../ && sudo git clone https://github.com/dride/drideOS-image-generator && cd drideOS-image-generator && sudo ./build.sh

# drideOS (Raspbian) Stage Overview


Upon execution, `build.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables.

The following environment variables are supported:

 * `IMG_NAME` **required** (Default: unset)

   The name of the image to build with the current stage directories.  Setting
   `IMG_NAME=Raspbian` is logical for an unmodified RPi-Distro/pi-gen build,
   but you should use something else for a customized version.  Export files
   in stages may add suffixes to `IMG_NAME`.

 * `APT_PROXY` (Default: unset)

   If you require the use of an apt proxy, set it here.  This proxy setting
   will not be included in the image, making it safe to use an `apt-cacher` or
   similar package for development.

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

 * `DEPLOY_DIR`  (Default: `"$BASE_DIR/deploy"`)

   Output directory for target system images and NOOBS bundles.


A simple example for building Raspbian:

```bash
IMG_NAME='Raspbian'
```


## Docker Build

```bash
vi config         # Edit your config file. See above.
./build-docker.sh
```

If everything goes well, your finished image will be in the `deploy/` folder.
You can then remove the build container with `docker rm pigen_work`

If something breaks along the line, you can edit the corresponding scripts, and
continue:

```bash
CONTINUE=1 ./build-docker.sh
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

 - Stage 0, bootstrap.  The primary purpose of this stage is to create a
   usable filesystem.  This is accomplished largely through the use of
   `debootstrap`, which creates a minimal filesystem suitable for use as a
   base.tgz on Debian systems.  This stage also configures apt settings and
   installs `raspberrypi-bootloader` which is missed by debootstrap.  The
   minimal core is installed but not configured, and the system will not quite
   boot yet.

 - Stage 1, truly minimal system.  This stage makes the system bootable by
   installing system files like `/etc/fstab`, configures the bootloader, makes
   the network operable, and installs packages like raspi-config.  At this
   stage the system should boot to a local console from which you have the
   means to perform basic tasks needed to configure and install the system.
   This is as minimal as a system can possibly get, and its arguably not
   really usable yet in a traditional sense yet.  Still, if you want minimal,
   this is minimal and the rest you could reasonably do yourself as sysadmin.

 - State 2, lite system.  This stage produces the Raspbian-Lite image.  It
   installs some optimized memory functions, sets timezone and charmap
   defaults, installs fake-hwclock and ntp, wifi and bluetooth support,
   dphys-swapfile, and other basics for managing the hardware.  It also
   creates necessary groups and gives the pi user access to sudo and the
   standard console hardware permission groups.

