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
STAGE=2

# Build rootfs
sudo ./build.sh --username=${USERNAME} --password=${PASSWORD} --hostname=${HOSTNAME} --imagename=${IMAGENAME}

# Create .img
sudo ./create-image.sh --imagename=${IMAGENAME} --stage=${STAGE}

# Resulting image will be at images/${IMAGENAME}
```