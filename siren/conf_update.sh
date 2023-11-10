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