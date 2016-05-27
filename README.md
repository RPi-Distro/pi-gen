#TODO

- NOOBS export
- Simplify running a single stage
- Documentation

#Dependencies
`quilt kpartx realpath qemu-user-static debootstrap zerofree`

# Example build script:

```bash
#!/bin/bash -e

# Set build variables
USERNAME=pi
PASSWORD=raspberry
HOSTNAME=raspberrypi
IMAGENAME="raspbian-lite-$(date +%Y-%m-%d)"

# Build rootfs
sudo ./build.sh --username=${USERNAME} --password=${PASSWORD} --hostname=${HOSTNAME} --imagename=${IMAGENAME}

# Resulting images will be in deploy/
```