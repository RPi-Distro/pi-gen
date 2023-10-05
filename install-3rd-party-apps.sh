#!/bin/sh

# Grab default system Sound Device from aplay -L
DEVICE=`aplay -L | grep sysdefault`

#
#  S H A I R P O R T

# Get Tools and Libraries
sudo apt update
sudo apt -y upgrade
sudo apt -y install --no-install-recommends \
                build-essential git autoconf automake libtool \
                libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev \
                libplist-dev libsodium-dev libavutil-dev libavcodec-dev libavformat-dev uuid-dev libgcrypt-dev xxd \
                libpulse-dev

# Build and Install nqptp
git clone https://github.com/mikebrady/nqptp.git
cd nqptp
autoreconf -fi
./configure --with-systemd-startup
make
sudo make install
cd ..

# Enable and Start nqptp
sudo systemctl enable nqptp
sudo systemctl start nqptp

# Build and Install Shairport
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-pa \
    --with-soxr --with-avahi --with-ssl=openssl --with-systemd --with-airplay-2
make
sudo make install
cd ..

# Start Shairport
shairport-sync &

# Run at startup - must be user service to interact with PulseAudio
mkdir -p ~/.config/systemd/user
cat << EOF > ~/.config/systemd/user/shairport-sync.service
[Unit]
Description=Shairport
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/shairport-sync
Restart=on-abort

[Install]
WantedBy=default.target
EOF

systemctl --user enable shairport-sync.service
systemctl --user start shairport-sync.service


#
#  R A S P O T I F Y
curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

# Set card for Raspotify to use
sudo sed -i "s\#LIBRESPOT_DEVICE=\"default\"\LIBRESPOT_DEVICE=\"${DEVICE}\"\g" /etc/raspotify/conf


#
#  R O O N  B R I D G E
curl -O https://download.roonlabs.net/builds/roonbridge-installer-linuxarmv7hf.sh
chmod +x roonbridge-installer-linuxarmv7hf.sh
yes Y | sudo ./roonbridge-installer-linuxarmv7hf.sh
