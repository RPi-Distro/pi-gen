![JNS Logo](/usr/local/share/wp_jns_logo_small_5_260x.gif)

# Jambox: Jamming with Raspberry Pi
## *Jazz Night School Edition*
Release 1.3.0

## Changes from v1.2.0:
- **New Jamming Apps: JamTaba, QJackTrip**
- **"Audio Device Settings" on desktop (pimixer) allows control of internal interface settings.**
    - changes should be persistent unless overriden by the app config items MASTER_LEVEL and CAPTURE_LEVEL settings (comment them out if you don't want that)
- **Device settings in /etc/jackdrc.conf can be customized by app or by pi model.**
    - this file is now a bit more complex, but in most cases it should "just work".
    - in most cases, the only setting you might need to change is "NPERIODS" (decrease to lower delay, increase to get rid of distortion clicks, pops)
    - Pi3 default setting has been changed to use PERIOD=128 (a bit more delay) to maximize audio quality.
- **System language can be changed**
    - Pi menu -> Preferences -> Localization
- **Jamulus Server startup simplifed and placed on Desktop**
- **Bug fixes and performance improvements**

If you don't want to read the "Quickstart" section, scroll to the bottom to read "Other Topics".

## Quickstart:

### Get Wired:
- **Raspberry Pi** Jambox has been tested primarily with Pi4B, but has also been verified to work on Pi3B.
- **Ethernet cable** between Raspberry Pi and your router (can't use wireless for jamming, too much jitter).
- **Headphones** to Headphone Amplifier (Rockville HPA-4 recommended) or headphone out of audio interface.
- **Headphone Amp power supply**
- **Raspberry Pi power supply** to USB-C port on Raspberry Pi 4, or micro USB port on Raspberry Pi 3B
- **USB Audio Interface** to a USB port on Raspberry Pi
    - Behringer UM2 is a good choice if you are buying an interface only for jamming.
    - verified to work with Behringer UCA222
    - verified to work with Focusrite 2i2.
    - other 2-channel recording interfaces are likely to work
    - other interfaces may require editing parameters in /etc/jackrdc.conf
- **Microphone and/or instrument** to USB Audio Interface
    - Microphone preamp requires XLR cable (don't connect microphone to 1/4" jack)
    - Guitar/Bass to channel 2 (so channel 1 can be used for talkback)
    - Keyboard can be wired as mono into channel 2, using channel 1 for talkback microphone.
    - Stereo keyboard sounds best when using both channels (1/4" jacks)
    - But in that case, talkback mic will requre a mixer in front of the USB Audio Interface
### Fire It Up:
- **Turn On Power** to Raspberry Pi using the switch in the power cable.
- **Wait a Minute or Two** for the Raspberry Pi to boot up.
- **Use a Web Browser** to connect to the Jambox user interface.
    - laptop, tablet, or desktop.  phone screen is likely too small to be practical.
    - go to [urlrelay.com/go](urlrelay.com/go)
    - This will redirect to your Jambox (if it's the only one recently on your local network).
    - If more than 1 Jambox on same local network, use the full url from the label on the box
    - click "Connect" on noVNC screen to bring up Raspberry Pi desktop

## Connect using Jamulus (server-based) or SonoBus (peer-to-peer)

### (Automatically) Connect to JNS Jamulus Server:
- Jamulus is set to automatically launch and connect to room1.jazznightschool.org
- After 2 hours of Jamulus, system will automatically shut the system down
- If it shuts down and you need more time, power off & back on)
- If you close Jamulus before the 2 hour timeout, it won't automatically shut down.
- If Jamulus isn't running, double-click "Jamulus Start" to launch Jamulus startup script.
- JNS Jamulus server address:  room1.jazznightschool.org

###Jamulus
+ **Connect to a Jamulus Server:**
    - Jamulus may be set to automatically launch on boot.  It may also be set to auto-connect to a server.
    - Otherwise, double-click on the "Jamulus Start" icon on the desktop. Then click "Connect" and choose a server.
    - If you have auto-connected to a server, then after 2 hours of Jamulus, system will automatically shut down
    - If it shuts down and you need more time, power off & back on)
    - If you close Jamulus before the 2 hour timeout, it won't automatically shut down.
+ **Personalize It:**
    - View -> My Profile, then set your Name, Instrument, City, and Skill.
    - View -> Chat to see the chat window to message other musicians.
+ **Jamulus Features:**
    - Input level meters:  This is the audio you are sending; keep it out of the red.
    - Level and Pan controls for each musician (your own Personal Mix!)
+ **Jamulus Settings:**
    - Jitter Buffer: Start with *Auto*, wait a min or two to settle, then increase each jitter buffer by 1 or 2 for better audio quality.. 
    - Enable Small Network Buffers: Recommended.  Lowers delay, but uses more bandwidth.
    - Audio Channels: *Mono-in/Stereo-out* - recommended for most users.  It will mix both channels from USB Audio Interface into one (for mic or mono instrument)
    - Audio Channels: *Stereo* is for stereo sources like stereo keyboard or multiple microphones.
    - Audio Quality: *High*: Recommended.  Uses more bandwidth than *Normal* but sounds better.
    - Skin: *Fancy* looks nice, but *Normal* and especially *Compact* fit more musicians on the screen.
    - Overall Delay: Useful number to watch.    30 ms = Fun; 50 ms = Not so much
+ **Jamulus Software Manual:** [https://jamulus.io/wiki/Software-Manual](https://jamulus.io/wiki/Software-Manual)

### SonoBus
+ **Connect with your group:**
    - Click "Connect" to get started
    - Enter your group's chosen "Group Name" that your group will use to find each other.
    - Enter "Your Displayed Name" for others in your group to see
    - Click "Connect to Group"
+ **SonoBus Features:**
    - "Monitor Level is what you hear (has no effect on what others hear).
    - "Output Level" is the what you are sending to others.
+ **SonoBus User Guide:** [https://www.sonobus.net/sonobus_userguide.html](https://www.sonobus.net/sonobus_userguide.html)
+ **Port Forwarding May Be Required** peer-to-peer apps may require port forwarding to be set up on certain routers, especially if multiple peers are used.

### JamTaba
+ **JamTaba Features**
    - Client for NINJAM servers - see [https://www.cockos.com/ninjam/](https://www.cockos.com/ninjam/)
    - Jamming is based on synchronized intervals of measures - you hear and play with what everyone else played during the last interval.
    - Not suited for all musical styles.
    - Jamming over very long distances is possible (i.e. musicians from 4 different continents).
+ **JamTaba user guide:** [https://github.com/elieserdejesus/JamTaba/wiki/Jamtaba%27s-user-guide](https://github.com/elieserdejesus/JamTaba/wiki/Jamtaba%27s-user-guide)

### QJackTrip
+ **QJackTrip Features**
    - GUI wrapper for JackTrip - see Section 3, "Using QJackTrip": [https://www.psi-borg.org/other-dev.html](https://www.psi-borg.org/other-dev.html)
    - qjacktrip can also be used from command line, with same arguments as JackTrip.

### Play!
- **Make sure that "Direct Monitor" on your USB Audio Interface is "off" (pushbutton out for Behringer UM2).**
- For Jamulus, **listen and play to the mix coming from the server.**  Your brain will quickly adapt to any delay, up to a point.
- If you run a simultaneous video call to see each other, don't use it for audio - all call participants should mute their mics.
- The Behringer UM2 features:
    - Clipping LED for each channel
    - Input Level controls for both channels:  (try to avoid lots of clipping)

### Wrap Up
- Jamulus and Sonobus each have a "Disconnect" button which will kill your connection.
- Closing the program ("x" in upper right) will exit the startup script.
- To shut the system down, double-click the "Power Off" button on the desktop, wait 1 min for full shutdown, then power off the Raspberry Pi.
- Try to avoid shutting down by simply killing power, it can corrupt the SD card and make system unbootable.
---
### Other Topics
+ **Getting & Giving Help**
    - Questions: Start a Discussion or answer a question on github: [https://github.com/kdoren/jambox-pi-gen/discussions](https://github.com/kdoren/jambox-pi-gen/discussions)
    - Bugs/Problems: Open an issue on GitHub: [https://github.com/kdoren/jambox-pi-gen/issues](https://github.com/kdoren/jambox-pi-gen/issues)
+ **Updating Jammming Apps (Jamulus - SonoBus - QJacktrip - JamTaba)**
    - Jamming apps are installed as apt packages from repo.jambox-project.com, so can be easily updated.
    - To update, double-click the "Update Apps" desktop icon.
+ **Updating Jambox**
    - Updating other jambox scripts, etc., currently requires flashing a new image to a micro SD card.
    - Check GitHub for new releases: [https://github.com/kdoren/jambox-pi-gen/releases](https://github.com/kdoren/jambox-pi-gen/releases)
    - It's not recommended to run  "sudo apt update && sudo apt-get upgrade" to blanket update other packages.  Probably safe but risks breaking something.  Better to update only specific packages if you have a reason.
+ **Customizable Settings**
    - See file README.md on github: [https://github.com/kdoren/jambox-pi-gen](https://github.com/kdoren/jambox-pi-gen)
+ **Running a Jamulus Server**
    - Jamulus server can run on Raspberry Pi.  It's best run on its own separate box.  Running on the same Raspberry Pi that runs a Jamulus Client will increase jitter.
    - Your internet connection needs enough upstream bandwidth to send streams to multiple clients.  DSL and Cable internet typically don't have very much.
    - If you run a private server, your router will require port forwarding to be set up.
    - Most customizable settings can be controlled from the Jamulus Server GUI, and are persistent.
    - The NUMCHANNELS (default 10) and PORT (default 22124) settings are set in the file /home/pi/.config/Jamulus/jamulus-server.conf
    - To start: Double-click the "Jamulus Server Start" desktop icon, or from command line:  "sudo systemctl start jamulus-server"
    - To auto-start jamulus-server at boot time:  "sudo systemctl enable jamulus-server"
    - If you want to enable session recording (experimental on Raspberry Pi), a USB3 SSD is recommended.
+ **Patch Changes**
    - Please see the topic "How do I change patches" on GitHub: [https://github.com/kdoren/jambox-pi-gen/discussions](https://github.com/kdoren/jambox-pi-gen/discussions)

#### Questions?
Contact: Kevin Doren   *kevin@doren.org*
