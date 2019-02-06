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

--------------
One time setup
--------------

Install the Raspbian compiler [1] and put it on your PATH.

[1]: https://github.com/wpilibsuite/raspbian-toolchain/releases

--------
Building
--------

Run "make"

---------
Deploying
---------

On the rPi web dashboard:

1) Make the rPi writable by selecting the "Writable" tab
2) In the rPi web dashboard Application tab, select the
   "Uploaded C++ executable" option for Application
3) Click "Browse..." and select the "multiCameraServerExample" executable in
   your desktop project directory
4) Click Save

The application will be automatically started.  Console output can be seen by
enabling console output in the Vision Status tab.
