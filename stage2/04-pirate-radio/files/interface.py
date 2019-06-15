"""This module is a systemd service that takes care of interfacing the
physical interaction devices (buttons, LEDs...) and the software of the
radio.
"""
import subprocess
import time
from contextlib import contextmanager

import phatbeat
import systemd.daemon
from mpd import MPDClient
from mpd.base import CommandError

HOST, PORT = 'localhost', 6600
VOLUME_STEP = 10

client = MPDClient()

@contextmanager
def connection_to_mpd():
    """Context manager to establish the connection with MPD.

    Should be used for every use of the client since the connection is
    sketchy.
    """
    try:
        client.connect(HOST, PORT)
        yield
    finally:
        client.close()
        client.disconnect()

# if the playlist is empty and an .m3u file has been provided then initialize
with connection_to_mpd():
    if not client.playlist():
        try:
            client.load("my-playlist")
        except(CommandError):
            pass

# Make sure we are not in the stop position (does not affect pause)
# and make sure we are in repeat mode to avoid falling in the stopped
# position when we hit the end of the playlist by pushing next on the
# last radio station of the playlist.
with connection_to_mpd():
    client.play()
    client.repeat(1)

# all initialization is considered done after this point and we tell
# systemd that we are ready to serve
systemd.daemon.notify('READY=1')

@phatbeat.on(phatbeat.BTN_VOLDN)
def volume_down(pin):
    """Volume down button tells pulseaudio to step down the volume."""
    command = """pactl
                set-sink-volume
                0
                -{}%
                """.format(VOLUME_STEP)
    subprocess.run(command.split())

@phatbeat.on(phatbeat.BTN_VOLUP)
def volume_up(pin):
    """Volume up button tells pulseaudio to step up the volume."""
    command = """pactl
                set-sink-volume
                0
                +{}%
                """.format(VOLUME_STEP)
    subprocess.run(command.split())

@phatbeat.on(phatbeat.BTN_PLAYPAUSE)
def play_pause(pin):
    """Play/pause button tells MPD to toggle play/plause."""
    with connection_to_mpd():
        client.pause()

@phatbeat.on(phatbeat.BTN_FASTFWD)
def next(pin):
    """Next button tells MPD to play next track."""
    with connection_to_mpd():
        client.next()

@phatbeat.on(phatbeat.BTN_REWIND)
def previous(pin):
    """Previous button tells MPD to play previous track."""
    with connection_to_mpd():
        client.previous()

@phatbeat.on(phatbeat.BTN_ONOFF)
def shutdown(pin):
    """Shutdown button tells the system to shutdown now."""
    command = """shutdown
                -h now
                """
    subprocess.run(command.split())

# maintain the module loaded for as long the the interface is needed
# without conuming resources
while True:
    time.sleep(5)
