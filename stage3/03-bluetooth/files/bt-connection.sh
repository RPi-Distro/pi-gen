#!/bin/bash
logger "${NAME} successfully connected"
if [[ $(whoami) == "root" ]]; then
	/bin/su - pi -c '/usr/bin/pactl upload-sample /usr/local/share/sounds/success.wav && /usr/bin/pactl play-sample success'
else
	/usr/bin/pactl upload-sample /usr/local/share/sounds/success.wav && /usr/bin/pactl play-sample success
fi
