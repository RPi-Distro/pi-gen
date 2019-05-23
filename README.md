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
- First clone this repository with `git clone --recursive git@github.com:pirateradiohack/PiRadio.git`.  
(Please note the `--recursive` here is important to get all the code, there is a submodule present.)
- Configure your radio stations: Pimoroni maintains a set of default internet radio streams. You can see them in the file `example.m3u`. This file will be installed if nothing else is supplied. If you create a file called `my-playlist.m3u` with your own list of internet radio streams, this file will be used instead.
- Configure your wifi settings: copy the file called `config.example` to `config` and edit this last one. You will see where to enter your wifi name, password and country. All 3 settings are necessary.
- Then build the image. (You can see the whole guide on the official RaspberryPi repo: https://github.com/RPi-Distro/pi-gen). I find it easier to use docker as there is nothing else to install, just run one command from this directory: `./build-docker.sh`. That's it. On my computer it takes between 15 and 30 minutes. And at the end you should see something like: `Done! Your image(s) should be in deploy/`  
If you don't see that, it's probably that the build failed. It happens to me sometimes for no reason and I find that just re-launching the build with `CONTINUE=1 ./build-docker.sh` finishes the build correctly.

## burn the image to a SD card
You should find the newly created image in the `deploy` directory. On linux an example to get it on the SD card would be:  
`sudo dd bs=4M if=deploy/2019-05-23-Piradio-lite.img of=/dev/mmcblk0 conv=fsync`  
(of course you need to replace `/dev/mmcblk0` with the path to your own SD card. You can find it with the command `lsblk -f`)
Those settings are recommended by the RaspberryPi instructions.
 
## controlling your radio via web interface
You can control your radio via web interface: find its IP and in your browser enter `http://[IP of your radio]:8080` with no username and password `raspberry`.

## ready-to-flash image
Out of security concerns I recommend you read the [code](https://github.com/RPi-Distro/pi-gen/compare/master...pirateradiohack:master) and build the image yourself.  
But, if you prefer to trust a stranger on the Internet with your Pirate Radio, for your convenience you will find the latest image pre-compiled here: [2019-05-23-Piradio-lite.img](https://github.com/pirateradiohack/PiRadio/releases/download/2019-05-23-PiRadio/2019-05-23-Piradio-lite.img) . Just flash it
and configure your wifi. You can also optionally configure your own radio streams playlist.

The files to edit are:
- wifi: `/etc/wpa_supplicant/wpa_supplicant.conf` (edit this file)
- playlist: `/home/pi/.config/vlc/playlist.m3u` (create this file)

You can edit them before or after flashing the image:
- before flashing you can mount the `.img`.  
With a modern operating system you probably just have to click the .img.  
With Linux you can use `kpartx` (from the `multipath-tools` package) to be able to mount the partition directly: `sudo kpartx -a path/to/2019-05-23-Piradio-lite.img` followed by `sudo mount /dev/mapper/loop0p2 tmp/ -o loop,rw`  
(you will need to create the mount directory first and check what loop device you are using with `sudo kpartx -l path/to/2019-05-23-Piradio-lite.img`). Then you can edit the files mentionned above. And `sudo umount tmp`.  
You are safe to flash the image.
- after flashing your operating system probably automounts the partitions.
