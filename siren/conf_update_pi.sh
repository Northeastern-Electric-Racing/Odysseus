#!/bin/bash

# this script copies the configuration files into their FS appropriate positions.

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


echo "Copying confs"
cp "$SCRIPT_DIR/mosquitto.conf" "/etc/mosquitto/conf.d/siren.conf"
cp "$SCRIPT_DIR/acl.conf" "/etc/mosquitto/acl.conf"

# change the acl_file location to be correct, specifically regex matches all acl_file at beginning of line, then replaces whole line with acl_file /etc/mosquitto/acl.conf
sed -i '/^acl_file*/s/.*/acl_file\\ \/etc\/mosquitto\/acl.conf/' "/etc/mosquitto/conf.d/siren.conf"