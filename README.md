#TODO

1. Documentation

#Dependencies

`quilt kpartx realpath qemu-user-static debootstrap zerofree pxz zip`

#Config

Upon execution, `build.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables.

The following environment variables are supported:

 * `IMG_NAME`, the name of the distribution to build (required)
 * `APT_PROXY`, proxy/cache URL to be included in the build
 * `MAX_STAGE`, to only run up to this stage. (default `4`, eg: `MAX_STAGE=2`)
 * `RUN_STAGE`, to only run a single stage (eg: `RUN_STAGE=1`)

A simple example for building Raspbian:

```bash
IMG_NAME='Raspbian'
```

#Stage Anatomy



#Raspbian Stage Overview

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

   There are a few tools that may not make a whole lot of sense here for
   development purposes on a minimal system such as basic python and lua
   packages as well as the `build-essential` package.  They are lumped right
   in with more essential packages presently, though they need not be with
   pi-gen.  These are understandable for Raspbian's target audience, but if
   you were looking for something between truly minimal and Raspbian-lite,
   here's where you start trimming.

 - Stage 3, desktop system.  Here's where you get the full desktop system
   with X11 and LXDE, web browsers, git for development, Raspbian custom UI
   enhancements, etc.  This is a base desktop system, with some development
   tools installed.

 - Stage 4, complete Raspbian system.  More development tools, an email
   client, learning tools like Scratch, specialized packages like sonic-pi and
   wolfram-engine, system documentation, office productivity, etc.  This is
   the stage that installs all of the things that make Raspbian friendly to
   new users.
