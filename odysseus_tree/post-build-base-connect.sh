#!/bin/sh

# hashes the password so it cannot be read in a dsitributed image (does not secure wifi!)
# this regex extras the part after psk=
hashed_block=$(wpa_passphrase "Hermes" "$ODY_BASE_WIFI_PASSWORD" | sed  -n -e 's/^.*[[:space:]]psk=//p')

# this replaces the psk in the target directory with the hashed block found above
sed -i "s/\(psk=\)\(.*\)/\1$hashed_block/" "$TARGET_DIR"/etc/wpa_supplicant_base.conf
