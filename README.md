## Using Rasbperry Pi Kolibri image

1. Download the zip file from the releases page
2. Use any of the method explained at https://www.raspberrypi.org/documentation/installation/installing-images/README.md to write the image to a SD card
3. Insert the SD card in the Raspberry PI
4. Power on the Rasperry Pi and wait ( The process takes less than 5 minutes in a model 4. Depending on the model it can take longer)
5. Enjoy it!


This image sets up the Raspberry Pi to provide wifi using the essid `kolibri` without any password.

After connecting a device to this wifi, opening the url http://10.10.10.10 in a browser will allow you enjoy all the features of a working kolibri server. 

By default the server does not have Internet access, so an usb disk must be used to add content channels to Kolibri.

In case you want to login into the server, the user is `pi` and the password is `kolibrifly`

VERY IMPORTANT: After installing the image, a ssh server is installed with a known password. CHANGE IT in case you want to connect it to Internet or be used by people who could mess it up.
