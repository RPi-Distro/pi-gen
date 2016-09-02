#TODO

1. Simplify running a single stage
1. Documentation

#Dependencies

`quilt kpartx realpath qemu-user-static debootstrap zerofree pxz`

#Config

Environment and other variables may be provided in a file named `config` in
your current working directory when you run `build.sh`.  At the moment, the
only thing you must configure is the name of the image to create.  Something
like this is used for Raspbian:

```bash
IMG_NAME='Raspbian'
```

Obviously if you are making changes to the pi-gen stages you should probably
use a different `IMG_NAME` to avoid confusion.

You can also define `APT_PROXY` here if you need to.
