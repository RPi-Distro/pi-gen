#!/bin/bash

# Disable dhcpcd - it has a conflict with cloud-init network config
systemctl mask dhcpcd

cat > /etc/cloud/cloud.cfg <<EOC
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
- default

# If this is set, 'root' will not be able to ssh in and they
# will get a message to login instead as the above $user (debian)
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# This prevents apt/sources.list from being updated at boot time
apt_preserve_sources_list: true

# configure NoCloud datasource to load user-data and meta-data from /boot
datasource_list: [ NoCloud, None ]
datasource:
  NoCloud:
    # read from boot partition instead of partition with cidata label as
    # bootfs is FAT formatted and can easily be edited on all OSes,
    # remove or comment if you want to use a cidata partition
    # (e.g. iso created via genisoimage)
    fs_label: boot

# The modules that run in the 'init' stage
cloud_init_modules:
- migrator
- seed_random
- bootcmd
- [write-files, always]
- growpart
- resizefs
- disk_setup
- mounts
- set_hostname
- update_hostname
- update_etc_hosts
- ca-certs
- rsyslog
- [users-groups, always]
- ssh

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
- emit_upstart
- ssh-import-id
- locale
- [set-passwords, always]
- grub-dpkg
- apt-pipelining
- apt-configure
- ntp
- timezone
- disable-ec2-metadata
- [runcmd, always]
- byobu

# The modules that run in the 'final' stage
cloud_final_modules:
- package-update-upgrade-install
- fan
- puppet
- chef
- salt-minion
- mcollective
- rightscale_userdata
- scripts-vendor
- scripts-per-once
- scripts-per-boot
- scripts-per-instance
- scripts-user
- ssh-authkey-fingerprints
- keys-to-console
- phone-home
- final-message
- power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
  # This will affect which distro class gets used
  distro: debian
  # Default user name + that default users groups (if added/used)
  default_user:
    name: pi
    # lock password login for pi user, making default password unusable
    # change to false, in case applying user-data failed and you're locked out
    lock_passwd: true
  # Other config here will be given to the distro class and/or path classes
  paths:
    cloud_dir: /var/lib/cloud/
    templates_dir: /etc/cloud/templates/
    upstart_dir: /etc/init/
  package_mirrors:
  - arches: [default]
    failsafe:
      primary: http://deb.debian.org/debian
      security: http://security.debian.org/
  ssh_svcname: ssh
EOC
