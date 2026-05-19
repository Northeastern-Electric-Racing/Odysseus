#!/bin/sh

# Become an Access Point

mv /etc/init.d/off_S41hostapd /etc/init.d/S41hostapd
mv /etc/init.d/off_S80dnsmasq /etc/init.d/S80dnsmasq

sed -i 's/^AP=0$/AP=1/' /sbin/quicknet

sed -i \
  -e 's/^# *nohook wpa_supplicant$/nohook wpa_supplicant/' \
  -e '/^#/!s/^static routers=/#&/' \
  -e '/^#/!s/^static domain_name_servers=/#&/' \
  /etc/dhcpcd.conf
