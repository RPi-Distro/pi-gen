# Piradio
Piradio is the image that you need to burn on your SD card in order for your Pirate Radio to work.

Pirate Radio here refers to the product sold by Pimoroni here: https://shop.pimoroni.com/products/pirate-radio-pi-zero-w-project-kit

Piradio specifically implements the internet radio project described here: https://github.com/pimoroni/phat-beat/tree/master/projects/vlc-radio


## motivation
The official documentation from Pimoroni suggest that you install the operating system and then execute some scripts on there to install the project.

I personally find it more convenient when it comes to embedded devices to just burn an image to an SD card.

## how it is built
The image is built with the official RaspberryPi.org tool (https://github.com/RPi-Distro/pi-gen) and the official scripts from Pimoroni (https://github.com/pimoroni/phat-beat/tree/master/projects/vlc-radio) adapted to work together. 

Nothing has been changed or otherwise improved from the original scripts, so the image you get here is the same as if you would install it the official way.

## how to create the image
- First clone this repository.  
- Configure your radio stations: Pimoroni maintains a set of default internet radio streams. You can see them in the file `example.m3u`. This file will be installed if nothing else is supplied. If you create a file called `my-playlist.m3u` with your own list of internet radio streams, this file will be used instead.
- Configure your wifi settings: copy the file called `config.example` to `config` and edit this last one. You will see where to enter your wifi name, password and country. All 3 settings are necessary.
- Then build the image. (You can see the whole guide on the official RaspberryPi repo: https://github.com/RPi-Distro/pi-gen). I find it easier to use docker as there is nothing else to install, just run one command from this directory: `./build-docker.sh`. That's it. On my computer it takes between 15 and 30 minutes. And at the end you should see something like: `Done! Your image(s) should be in deploy/`  
If you don't see that, it's probably that the build failed. It happens to me sometimes for no reason and I find that just re-launching the build with `CONTINUE=1 ./build-docker.sh` finishes the build correctly.

## burn the image to a SD card
You should find the newly created image in the `deploy` directory. On linux an example to get it on the SD card would be:  
`sudo dd bs=4M if=deploy/2019-05-22-Piradio-lite.img of=/dev/mmcblk0 conv=fsync`  
(of course you need to replace `/dev/mmcblk0` with the path to your own SD card. You can find it with the command `lsblk -f`)
Those settings are recommended by the RaspberryPi instructions.
 
## web control
You can control your radio via web interface: find its IP and in your browser enter `http://[IP of your radio]:8080` with no username and password `raspberry`.
