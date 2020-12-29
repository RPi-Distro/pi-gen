# Jambox: Jamming with Raspberry Pi
Release 1.2.0

## Quickstart:

### Get Wired:
- **Ethernet cable** between Raspberry Pi and your router (can't use wireless with Jamulus)
- **Headphones** to Headphone Amplifier (Rockville HPA-4 recommended) or headphone out of audio interface.
- **Headphone Amp power supply**
- **Raspberry Pi power supply** to USB-C port on Raspberry Pi 4, or micro USB port on Raspberry Pi 3B
- **USB Audio Interface** to a USB port on Raspberry Pi
    - Behringer UM2 is a good choice
    - verified to work with Behringer UCA222
    - verified to work with Focusrite 2i2
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

###Jamulus
+ **Connect to a Jamulus Server:**
    - Jamulus may be set to automatically launch on boot.  It may also be set to auto-connect to a server.
    - Otherwise, double-click on the "Jamulus Start" icon on the desktop. 
    - After 2 hours of Jamulus, system will automatically shut down
    - If it shuts down and you need more time, power off & back on)
    - If you close Jamulus before the 2 hour timeout, it won't automatically shut down.
    - If Jamulus isn't running, double-click "Jamulus Start" to launch Jamulus startup script.
+ **Personalize It:**
    - View -> My Profile, then set your Name, Instrument, City, and Skill.
    - View -> Chat to see the chat window to message other musicians.
+ **Jamulus Features:**
    - Input level meters:  This is the audio you are sending; keep it out of the red.
    - Level and Pan controls for each musician (your own Personal Mix!)
+ **Jamulus Settings:**
    - Jitter Buffer: Start with *Auto*, wait a min or 2 to settle, then increase each jitter buffer by 2 for less breakup. 
    - Enable Small Network Buffers: Recommended.  Lowers delay, but uses more bandwidth.
    - Audio Channels: *Mono-in/Stereo-out* - recommended for most users.  It will mix both channels from USB Audio Interface into one (for mic or mono instrument)
    - Audio Channels: *Stereo* is for stereo sources like stereo keyboard or multiple microphones.
    - Audio Quality: *High*: Recommended.  Uses more bandwidth than *Normal* but sounds somewhat better.
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

### Play!
- **Make sure that "Direct Monitor" on your USB Audio Interface is "off" (pushbutton out for Behringer UM2).**
- For Jamulus, **listen and play to the mix coming from the server.**  Your brain will quickly adapt to any delay, up to a point.
- If you run a simultaneous video call to see each other, don't use it for audio - all call participants should mute their mics.

### Wrap Up
- Jamulus and Sonobus each have a "Disconnect" button which will kill your connection.
- Closing the program ("x" in upper right) will exit the startup script.
- To shut the system down, double-click the "Power Off" button on the desktop, then wait 1 min for full shutdown.
- Try to avoid shutting down by simply killing power, it can corrupt the SD card and make system unbootable.
---
### Other Topics
+ **Getting & Giving Help**
    - Questions: Start a Discussion or answer a question on github: [https://github.com/kdoren/jambox-pi-gen/discussions](https://github.com/kdoren/jambox-pi-gen/discussions)
    - Bugs/Problems: Open an issue on GitHub: [https://github.com/kdoren/jambox-pi-gen/issues](https://github.com/kdoren/jambox-pi-gen/issues)
+ **Updating Jamulus or SonoBus**
    - Jamulus and SonoBus are installed as apt packages from repo.jambox-project.com, so can be easily updated.
    - To update, double-click the "Update" desktop icon.
+ **Updating Jambox**
    - Updating other jambox scripts, etc., currently requires flashing a new image to a micro SD card.
    - Check GitHub for new releases: [https://github.com/kdoren/jambox-pi-gen/releases](https://github.com/kdoren/jambox-pi-gen/releases)
    - It should be safe to run "sudo apt-get update && sudo apt-get upgrade" to update other packages.  But probably unnecessary unless you have a specific reason.
+ **Customizable Settings**
    - See file README.md on github: [https://github.com/kdoren/jambox-pi-gen](https://github.com/kdoren/jambox-pi-gen)
+ **Running a Jamulus Server**
    - Jamulus server can run on Raspberry Pi, either on a separate box, or on the same Raspberry Pi that runs a Jamulus Client.
    - Your internet connection needs to be able to handle the upstream bandwidth of sending streams to multiple clients.
    - You router will likely require port forwarding to be set up.
    - Customizable Settings are described in file /home/pi/.config/Jamulus/jamulus-server.conf
    - To start:  "sudo systemctl start jamulus-server"
+ **Patch Changes**
    - Please see the topic "How do I change patches" on GitHub: [https://github.com/kdoren/jambox-pi-gen/discussions](https://github.com/kdoren/jambox-pi-gen/discussions)
+ **JackTrip"**
    - There is another peer-to-peer jamming app called JackTrip which is also installed.  It's untested and unsupported. You can report your experiences in the JackTrip discussion category on jambox-pi-gen GitHub.
