#!/bin/sh

# Become a station, connect to Hermes/HermesBay

mv /etc/init.d/S41hostapd /etc/init.d/off_S41hostapd
mv /etc/init.d/S80dnsmasq /etc/init.d/off_S80dnsmasq

sed -i 's/^AP=1$/AP=0/' /sbin/quicknet

sed -i \
  -e 's/^nohook wpa_supplicant$/# nohook wpa_supplicant/' \
  -e 's/^#static routers=/static routers=/' \
  -e 's/^#static domain_name_servers=/static domain_name_servers=/' \
  /etc/dhcpcd.conf
