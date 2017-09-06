#!/bin/sh

echo 'HRNGDEVICE=/dev/hwrng' | tee --append /etc/default/rng-tools

systemctl enable rng-tools
