# Piradio [![Build Status](https://travis-ci.org/pirateradiohack/PiRadio.svg?branch=master)](https://travis-ci.org/pirateradiohack/PiRadio)
Piradio powers a streaming internet radio client for the "Pirate Radio" hardware sold by Pimoroni: https://shop.pimoroni.com/products/pirate-radio-pi-zero-w-project-kit
or any kit based on their Phat Beat DAC / Audio Amplifier and a Raspberry Pi.  
It also work with the smaller shim audio amp: https://shop.pimoroni.com/products/audio-amp-shim-3w-mono-amp

Features are the ones provided by [mpd](https://github.com/MusicPlayerDaemon/MPD):
- it retains the radio station that was playing after turning off / on the device and also the volume.
- it has a number of interfaces, currently on this image there is a web interface and a console one.
- managing your radio stations can be done from the interface (`add stream` and delete buttons).
- physical buttons on the Phat Beat do what is expected of them
- LEDs are used as a vumeter

## how to create the image
- First clone this repository with `git clone https://github.com/pirateradiohack/PiRadio.git`.  
- Configure your wifi settings: copy the file called `config.example` to `config` and edit this last one. You will see where to enter your wifi name, password and country. All 3 settings are necessary. Your changes to this file will be kept in future updates.
- Optionally configure your radio stations: If you create a file called `my-playlist.m3u` with your own list of internet radio streams, it will be installed.
If not, then you can always add stations in the web interface.
- Then build the image. (You can see the whole guide on the official RaspberryPi repo: https://github.com/RPi-Distro/pi-gen). I find it easier to use docker (obviously you need to have docker installed on your system) as there is nothing else to install, just run one command from this directory: `./build-docker.sh`. That's it. On my computer it takes between 15 and 30 minutes. And at the end you should see something like: `Done! Your image(s) should be in deploy/`  
If you don't see that, it's probably that the build failed. It happens to me sometimes for no reason and I find that just re-launching the build with `CONTINUE=1 ./build-docker.sh` finishes the build correctly.

## burn the image to a SD card
You should find the newly created image in the `deploy` directory.

### graphically
For a user friendly experience you can try [etcher](https://www.balena.io/etcher/) to flash the image to the SD card.

### manually
On linux (and it probably works on Mac too) an example to get it on the SD card would be:  
`sudo dd bs=4M if=deploy/2019-05-23-Piradio-lite.img of=/dev/mmcblk0 conv=fsync`
(of course you need to replace `/dev/mmcblk0` with the path to your own SD card. You can find it with the command `lsblk -f`)
Those settings are recommended by the RaspberryPi instructions.

## controlling your radio via web interface
You can control your radio via web interface: try to open `http://radio.local` in a web browser. If that does not work then find its IP and in your browser enter `http://[IP of your radio]`.


If you prefer the command line, you can ssh into your radio (you need to set that up in the `config` file before building the image) and then use `ncmpcpp` to get a nice terminal interface (see some screenshots here: https://rybczak.net/ncmpcpp/screenshots/).

## ready-to-flash image
Out of security concerns I recommend you read the [code](https://github.com/RPi-Distro/pi-gen/compare/master...pirateradiohack:master) and build the image yourself.


But, if you prefer to trust a stranger on the Internet with your Pirate Radio, for your convenience you will find the latest image pre-compiled here: [2020-07-28-Piradio-image.zip](https://github.com/pirateradiohack/PiRadio/releases/download/2020-07-28-PiRadio/image.zip).


Just flash it and configure your wifi. You can also optionally configure your own radio streams playlist.

The files to edit are:
- wifi: `/etc/wpa_supplicant/wpa_supplicant.conf` (edit this file)
- (optionally) playlist: `/home/pi/.config/vlc/playlist.m3u` (create this file)

You can edit them before or after flashing the image:
- before flashing you can mount the `.img`.  
With a modern operating system you probably just have to click the .img.  
With Linux you can use `kpartx` (from the `multipath-tools` package) to be able to mount the partition directly: `sudo kpartx -a path/to/2019-05-23-Piradio-lite.img` followed by `sudo mount /dev/mapper/loop0p2 tmp/ -o loop,rw`  
(you will need to create the mount directory first and check what loop device you are using with `sudo kpartx -l path/to/2019-05-23-Piradio-lite.img`). Then you can edit the files mentionned above. And `sudo umount tmp`.  
You are safe to flash the image.
- after flashing your operating system probably automounts the partitions.

## how it is built
The image is built with the official RaspberryPi.org tool (https://github.com/RPi-Distro/pi-gen) to build a Raspbian lite system with all the software needed
to have a working internet radio stream client. It uses `mpd`.

## motivation
The official documentation from Pimoroni has some instructions and examples to make an internet streaming client for the hardware: https://github.com/pimoroni/phat-beat/tree/master/projects/vlc-radio. It works fine and is a good source of inspiration.


But those examples assume an already installed OS and run some scripts on top of it.
I personally find it more convenient when it comes to embedded devices to just burn an image to an SD card.
Also, the provided software in the examples works fine, but comes in a format that I find hard to tinker with.
I tried to use an approach based on provisionning an image instead in order to make it a good ground for hacking.

The first version of this project used the official scripts from Pimoroni. If you want that, you can find it here: https://github.com/pirateradiohack/PiRadio/tree/2019-05-25-PiRadio


Issues and pull requests are welcome.

