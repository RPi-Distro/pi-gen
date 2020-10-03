![JNS Logo](/usr/local/share/wp_jns_logo_small_5_260x.gif)

# Jambox: Jamulus on Raspberry Pi 4
## *Jazz Night School Edition*

## Quickstart:

### Get Wired:
- **Ethernet cable** between Raspberry Pi and your router (can't use wireless with Jamulus)
- **Headphones** to Headphone Amplifier
- **Headphone Amp power supply**
- **Raspberry Pi power supply** to USB-C port on Raspberry Pi
- **Microphone and/or instrument** to USB Audio Interface
    - Microphone preamp requires XLR cable (do not connect microphone to 1/4" jack)
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

### (Automatically) Connect to JNS Jamulus Server:
- Jamulus is set to automatically launch and connect to room1.jazznightschool.org
- After 2 hours of Jamulus, system will automatically shut the system down
- If it shuts down and you need more time, power off & back on)
- If you close Jamulus before the 2 hour timeout, it won't automatically shut down.
- If Jamulus isn't running, double-click "Jamulus Start" to launch Jamulus startup script.
- JNS Jamulus server address:  room1.jazznightschool.org

### Personalize It:
- View -> My Profile, then set your Name, Instrument, City, and Skill.
- View -> Chat to see the chat window.  Not yet clear if/how this will be used by JNS ensembles.
- Settings:
    - Jitter Buffer:  recommend leaving set to *Auto*
    - Enable Small Network Buffers: lowers delay, but uses more bandwidth, with a bit more audio breakup.
    - Audio Channels: *Mono-in/Stereo-out* will mix both channels from USB Audio Interface into one (for mic or guitar)
    - Audio Channels: *Stereo* is good for stereo keyboard, but talkback mic will require an external mixer.
    - Audio Quality: *High* uses more bandwidth than *Normal* but sounds somewhat better.
    - Skin: *Fancy* looks nice, but *Normal* and especially *Compact* fit more musicians on the screen.
    - Overall Delay: Useful number to watch.    30 ms = Fun; 50 ms = Not so much

### Play!
- **Make sure that "Direct Monitor" on USB Audio Interface is "off" (pushbutton out).**
- **Listen to the Mix coming from the server.**  Your brain will quickly adapt to any delay, up to a point.
- Jamulus features:
    - Input level meters:  This is the audio you are sending; keep it out of the red.
    - Level and Pan controls for each musician (your own Personal Mix!)
- The Behringer UM2 features:
    - Clipping LED for each channel
    - Input Level controls for both channels:  (try to avoid lots of clipping)

### Wrap up
- Jamulus "Disconnect" button will kill your server connection.
- Closing Jamulus ("x" in upper right) will exit the Jamulus startup script, stopping the 2-hour timer.
- To shut the system down, double-click the "Stop Sign" button on the desktop, then wait 1 min for full shutdown.
- Try to avoid shutting down by simply killing power, it can corrupt the SD card and make system unbootable.

#### Questions?
Contact: Kevin Doren   *kevin@doren.org*
