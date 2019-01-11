======================
Deploying from desktop
======================

On the rPi web dashboard:

1) Make the rPi writable by selecting the "Writable" tab
2) In the rPi web dashboard Application tab, select the "Uploaded Python file"
   option for Application
3) Click "Browse..." and select the "multiCameraServer.py" file in
   your desktop project directory
4) Click Save

The application will be automatically started.  Console output can be seen by
enabling console output in the Vision Status tab.

========================
Deploying locally on rPi
========================

1) Copy multiCameraServer.py and runCamera to /home/pi
2) Run "./runInteractive" in /home/pi or "sudo svc -t /service/camera" to
   restart service.
