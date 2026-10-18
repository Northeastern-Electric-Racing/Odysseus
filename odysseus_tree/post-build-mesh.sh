#!/bin/sh

# append to the SSID an ID number
sed -i "s|^\(ssid=.*_\).*|\1${ODY_MESH_ID}|" "$TARGET_DIR"/etc/hostapd.conf

# change the static IP
sed -i "s|^\(\s*static ip_address=10\.42\.0\.\)[0-9X]\+/24|\1${ODY_MESH_ID}/24|" "$TARGET_DIR"/etc/dhcpcd.conf

# add the sae password
sed -i "s|^\(\s*sae_password=\)\".*\"|\1\"${ODY_MESH_SAE_PASSWORD}\"|" "$TARGET_DIR"/etc/wpa_supplicant_halow.conf
