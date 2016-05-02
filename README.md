#TODO

1. Image export
1. NOOBS export
1. Simplify running a single stage
1. Documentation

#Dependencies

`quilt kpartx realpath qemu-user-static debootstrap zerofree`

# Example usage to build a bootable raspbian lite image:
sudo ./build.sh
sudo ./create-image.sh --path=./work/2016-05-02-raspbian/stage3 --name="raspbian-lite"