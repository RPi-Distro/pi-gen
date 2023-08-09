I am having to resort to using a slow still capture since I don't have the python bindings for libcamera.  Try to find a better way.  To be honest though, it is kind-of OK for just playing with.

# Setting up the PI for this code

add the following lines to `/boot/config.txt`

~~~~~
enable_uart=1
dtoverlay=disable-bt
~~~~~

run the following commands on first boot
  * `> sudo install git`
  * `> git clone <repo>`
  * `> sudo apt-get install python3-pip`
  * `> sudo apt-get install libatlas-base-dev`
  * `> python -m pip install tflite-runtime`
  * `> sudo apt-get install libopenjp2-7-dev`
  * `> python -m pip install Pillow`
  * `> python -m pip install picamera`
  * enable legacy camera support

install [pi-clone](https://github.com/billw2/rpi-clone)
