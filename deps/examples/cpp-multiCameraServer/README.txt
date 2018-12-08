=======================
Building locally on rPi
=======================

1) Run "make"
2) Run "make install" (replaces /home/pi/runCamera)
3) Run "./runInteractive" in /home/pi or "sudo svc -t /service/camera" to
   restart service.


===================
Building on desktop
===================

One time setup
--------------

Install the Raspbian compiler [1] as well as GNU make.

[1]: https://github.com/wpilibsuite/raspbian-toolchain/releases

The lib and include directories from the Pi /usr/local/frc/ directory must
be copied to the desktop machine.  Edit the Makefile to change
/usr/local/frc/lib and /usr/local/frc/include to the local desktop locations.

Building
--------

1) Run "make CXX=arm-raspbian9-linux-gnueabihf-g++"
2) Copy multiCameraServerExample and runCamera to /home/pi on the Pi
3) On the Pi, run "./runInteractive" in /home/pi or
   "sudo svc -t /service/camera" to restart service.

