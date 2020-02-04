<img src="https://raw.githubusercontent.com/bitcointokenbtct/Official-Images/master/raspinode.jpg">

# Raspberry Pi BTCT Node

Based on the official Raspbian image, using pi-gen to create. Should work on any Pi hardware that supports Raspbian Buster. Tested on Pi4 w/ 4GB, Pi3 and Pi Zero.

Some notes:
  1. This version of the image includes a bootstrap of the BTCT chain current as of the day the image was created.

  2. SSH IS TURNED ON BY DEFAULT IN THIS IMAGE.  This allows you to get up and running with no monitor, keyboard or mouse connection.  Plug in your ethernet cable, use Putty or some other ssh client to access via ssh, and away you go.  If you want to use wifi, you will need an ethernet cable or monitor/keyboard to initially set up your wifi.

  3. If using this image on a Pi Zero, you must use the pi-zero binaries found in /home/pi/btct/bin/pi-zero. The pi-zero is btct-cli and btctd (daemon) only, the -qt wallet does not work on the Zero. 

## If you want to run the -QT wallet:

If no monitor, ssh in to your Pi and run ```sudo raspi-config``` then set VNC to on in Interface Options.

After booting up the GUI, go through the setup wizard and reboot.

Click on the raspberry menu at the top left and you should find Bitcoin Token (this is the -QT wallet).


## If you wan tto run only the daemon (btctd with btct-cli):

Use ```sudo raspi-config``` to do your setup.  If on a Pi2 or higher, use /home/pi/btct/bin/{btct files}.  If on a Pi Zero, use /home/pi/btct/bin/pi-zero/{btct files}.

## General Warning:

BE SURE TO ENCRYPT AND BACKUP YOUR WALLET! If you forget your password, no one can help you. If you are unsure what you are doing, come to the Discord server and ask -> https://discord.gg/4cAGCf4

NO ONE WILL EVER DM YOU AND ASK YOU FOR YOUR PASSWORD OR PRIVATE KEYS OR ANY OTHER INFORMATION. If someone claiming to be a BTCT admin (or anyone) does, block them and report to the mods of whatever servers you have in common with the scammer.

READ THE PARAGRAPH ABOVE AGAIN! NEVER GIVE OUT YOUR PASSWORD OR PRIVATE KEYS TO ANYONE UNLESS YOU LIKE HAVING ALL YOUR CRYPTO STOLEN FROM YOU.

## Hardware Recommendations

Anyone can run a Bitcoin Token BTCT RasPi Node. It is a simple way to have a 24/7 node on our network that not only helps the BTCT network to run but also can help you stake BTCT all the time and earn rewards.

Recommended hardware:

https://www.amazon.com/dp/B01N13X8V1/ - Raspberry Pi 3 Model B<br>
or<br>
https://www.amazon.com/dp/B07TD42S27/ Raspberry Pi 4 Model B<br>

https://amzn.to/2BNQHfm – Kingston Canvas React™ 32GB microSD card<br>
http://a.co/2c9FFaf – 8-Port Desktop USB Charger Charging Station<br>
http://a.co/8i5RHU3 – Short USB Cable, (the 10 pack is a good value) . (only if you are thinking to run multiple BTCT RasPi's)<br>
https://www.amazon.com/dp/B016A90URW/ - 1 foot ethernet (the 10 pack is a good value) (only if you are thinking to run multiple BTCT RasPi's)

Also, the Pi Zero makes a very good (and inexpensive) node if you are comfortable with the command line.

## Instructions for etching

Download the IMG file: https://github.com/bitcointokenbtct/BTCT-Rasp-Pi-Image/releases

Use Etcher (https://www.balena.io/etcher/). No need to unzip the image first, Etcher will do that for you. Just download and point etcher to the .zip file.

Use a 16GB SD Card minimum, but recommend you go for 32 or 64GB, the blockchain will grow. Get something with decent speed.

AGAIN: BE SURE TO ENCRYPT AND BACKUP YOUR WALLET! SD Cards can and will go bad. Back up your wallet and make sure you know the password.

## Next Steps

Simply power up your RasPi with the SD card in it. For those who are not using a mouse or screen connected to the RasPi there are additional steps you can google to connect to the RasPi via terminal. We will be expanding this help guide in the near future with more detailed steps.
