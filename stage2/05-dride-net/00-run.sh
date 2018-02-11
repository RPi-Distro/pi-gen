#!/bin/bash -e

# on_chroot << EOF
# bash -c "$(curl -s https://dride.io/code/install.sh)"
# EOF


on_chroot << EOC

#apt-get remove --purge hostapd -yqq
#apt-get update -yqq
#apt-get upgrade -yqq
#apt-get install hostapd dnsmasq -yqq

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=192.168.42.10,192.168.42.20,255.255.255.0,12h
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=ilovedride
ssid=dride
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
EOF

sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

cat >> /etc/network/interfaces <<EOF

auto usb0
allow-hotplug usb0
iface usb0 inet dhcp

# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
    address 192.168.42.1
    netmask 255.255.255.0
    network 192.168.42.0
    broadcast 192.168.42.255

EOF

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
sudo systemctl disable dhcpcd.service

sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

sudo service hostapd start
sudo service dnsmasq start

echo "All done! Please reboot"

EOC

# fix Stretch dhcpcd5 to not ignore in /etc/network/interfaces
install -m 644 files/usr_lib_dhcpcd ${ROOTFS_DIR}/usr/lib/dhcpcd5/dhcpcd
