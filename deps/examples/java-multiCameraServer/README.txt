=======================
Building locally on rPi
=======================

1) Run "./gradlew build"
2) Run "./install.sh" (replaces /home/pi/runCamera)
3) Run "./runInteractive" in /home/pi or "sudo svc -t /service/camera" to
   restart service.


===================
Building on desktop
===================

One time setup
--------------

Copy the .jar files from /home/pi/javalibs on the Pi to the source directory.

Building
--------

1) Run "./gradlew build"
2) Copy build/libs/java-multiCameraServer-all.jar and runCamera to /home/pi on
   the Pi.  Note: the .jar filename may be different; if it is, either rename
   when copying to the Pi or edit runCamera to reflect the new jar name.
3) On the Pi, run "./runInteractive" in /home/pi or
   "sudo svc -t /service/camera" to restart service.

