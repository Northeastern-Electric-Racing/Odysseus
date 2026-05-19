#!/bin/sh

# Add a password for wheel to hostapd

sed -i "s|^wpa_passphrase=.*|wpa_passphrase=${ODY_WHEEL_AP_PASSWORD}|" "$TARGET_DIR"/etc/hostapd.conf
