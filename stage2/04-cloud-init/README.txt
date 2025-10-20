Cloud-Init support for Raspberry Pi OS

Reference for Raspberry Pi custom cloud-init config module: https://cloudinit.readthedocs.io/en/latest/reference/modules.html#raspberry-pi-configuration

- files/network-config is required because otherwise imager would fail to create the correct filesystem entry

- files/user-data same reason and to include some example configurations

- files/meta-data Cloud-init instance configuration

