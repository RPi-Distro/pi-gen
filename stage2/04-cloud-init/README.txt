Cloud-init support for Raspberry Pi OS

TODO: add reference to official documentation for the custom modules when merged

- files/network-config is required because otherwise imager would fail to create the correct filesystem entry

- files/user-data same reason and to include some example configurations

- files/meta-data Cloud-init instance configuration

- files/cloud-init-custom.deb A custom cloud-init build until included apt repositories

- files/99_raspberry-pi.cfg Cloud-init datasource configuration

- files/00-network-manager-all.yaml Example form netplan docs/ubuntu for handing over control from 
netplan to NetworkManager by default.

Packages:
    - netplan is installed to provide for advanced options like "wifis" in the network-config v2
