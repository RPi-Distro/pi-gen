#Dependencies

`sudo apt-get update && sudo apt-get install git quilt kpartx realpath qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin -y &&
cd ../ &&
sudo git clone https://github.com/dride/drideOS-image-generator &&
cd drideOS-image-generator &&
sudo ./build.sh
`

#Stage Anatomy



# drideOS (Raspbian) Stage Overview

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

- Stage 3, Install Dride related softwere.
