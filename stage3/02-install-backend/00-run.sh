#!/bin/bash -e

on_chroot << EOF
apt-get update
apt-get install -y python3-pip python3-venv wget unzip lighttpd mosquitto mosquitto-clients python3-dev build-essential
EOF

on_chroot << EOF
cd /tmp
wget https://files.catbox.moe/0lrahk.zip -O backend.zip
unzip backend.zip
mv GardenBack-main /opt/gardenback
rm backend.zip
cd /opt/gardenback

# Setup Virtual Environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip3 install --upgrade pip

# Install requirements
pip3 install -r requirements.txt

# Initialize database
python3 -m alembic upgrade head

# Optionally seed database (uncomment if needed)
# python3 db/seed.py
EOF

# Set permissions
on_chroot << EOF
chown -R root:root /opt/gardenback
chmod -R 755 /opt/gardenback

# Create database directory if needed
mkdir -p /opt/gardenback/db
chmod 755 /opt/gardenback/db
EOF