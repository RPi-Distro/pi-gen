#!/bin/bash
echo 'Updating jamming apps in 5 seconds'
sleep 5
sudo apt-get update
sudo apt-get -y install jamulus sonobus jacktrip qjacktrip jamtaba
sleep 20
