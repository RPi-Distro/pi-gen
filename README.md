# Dependencies

    sudo apt-get update && sudo apt-get install git curl quilt parted realpath qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils -y && cd ../ &&
    sudo git clone https://github.com/dride/drideOS-image-generator && cd drideOS-image-generator && sudo ./build.sh

## Stage Anatomy

### (drideOS) Raspbian Stage Overview


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

----

###Explaination of changes vs. upstream main repo

The goal is to keep minimal changes from upstream such that pulling updates is easier.  Therefore we added Dride OS changes and software installation as subsequent steps within stage2.

* stage 0 - unchanged from upstream
* stage 1 - unchanged from upstream
* stage 2 - `00-copies-and-fills`, `01-sys-tweaks`, `02-net-tweaks` and `10-cleanup` are unchanged
* stage 3, 4, 5 - removed

NOTE: resizing the `root` parition apart of the stage 2 upstream step is overruled by a subsequent step (03-boot-files) found below.  Hence the root partition is **not** resized.

Changes/complimentary for DrideOS
Within Stage 2, the following additions have been made:

* `03-boot-files`
* `04-dride-filesystem`
* `05-dride-net`
* `06-dride-base`


`03-boot-files`

Modifies the boot config files to **enable** Ether over USB.  This is very helpful when you wish to plug your Dride via USB port into your computer and access via SSH.
This also keeps the Dride WiFi access point working as well.

`04-dride-filesystem`

Ommitted for this current version.

`05-dride-net`

Enable Dride WiFi access point.

`06-dride-base`

Install all the Dride software and any dependencies needed to run the software.
This takes an optional environment argument that will allow differentiation between two software modes.

The base software package - essentials - is installed if you do not provide any specific mention of the enviornment variable.  This consists of minimal software to get the Dride working.

```export OS_TYPE="dride-plus"```

Optionally, if you set the environment varable **before** build time - you can add additonal software features best reserved for a Raspberry Pi 3 or similar hardware.
