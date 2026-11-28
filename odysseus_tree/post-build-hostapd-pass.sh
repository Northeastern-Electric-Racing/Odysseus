#!/bin/sh

# Add a password for wheel or mesh to hostapd
eval "PASSWORD=\${ODY_${2}_AP_PASSWORD}"
sed -i "s|^wpa_passphrase=.*|wpa_passphrase=${PASSWORD}|" "$TARGET_DIR"/etc/hostapd.conf
