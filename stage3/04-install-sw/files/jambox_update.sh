#!/bin/bash
echo 'Updating jamulus, sonobus, jacktrip & jamtrip in 5 seconds'
sleep 5
sudo apt-get update
sudo apt-get -y install jamulus sonobus jacktrip jamtrip
sleep 20
