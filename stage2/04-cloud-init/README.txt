Cloud-init support for Raspberry Pi OS

Reference for Raspberry Pi custom cloud-init config module: https://cloudinit.readthedocs.io/en/latest/reference/modules.html#raspberry-pi-configuration

- files/network-config is required because otherwise imager would fail to create the correct filesystem entry

- files/user-data same reason and to include some example configurations

- files/meta-data Cloud-init instance configuration

- files/99_raspberry-pi.cfg Cloud-init datasource configuration

- files/00-network-manager-all.yaml Example from netplan docs/ubuntu for handing over control from 
netplan to NetworkManager by default.
