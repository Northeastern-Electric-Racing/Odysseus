#!/bin/sh

# hashes the password so it cannot be read in a dsitributed image (does not secure wifi!)
# this regex extras the part after psk=
hashed_block=$(wpa_passphrase "Hermes" "$ODY_BASE_WIFI_PASSWORD" | sed  -n -e 's/^.*[[:space:]]psk=//p')

# this replaces the psk in the target directory with the hashed block found above, only the first occurance (meaning Hermes must come before HermesField)
sed -i "0,/psk=/{s/psk=.*/psk=$hased_block/}" "$TARGET_DIR"/etc/wpa_supplicant_base.conf

hashed_block=$(wpa_passphrase "HermesField" "$ODY_BASE_WIFI_PASSWORD" | sed  -n -e 's/^.*[[:space:]]psk=//p')
# do the same thing in reverse
tac "$TARGET_DIR"/etc/wpa_supplicant_base.conf | sed "0,/psk=/{s/psk=.*/psk=$hased_block/}" | tac > "$TARGET_DIR"/etc/wpa_supplicant_base.conf

