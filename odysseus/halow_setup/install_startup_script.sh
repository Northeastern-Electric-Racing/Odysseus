#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

echo "Installing systemd file and associated commands"
chmod +x ./install/nrc-wizard
chmod +x ./install/nrc-led
# /usr/local/sbin is standard for user installed scripts, it is in path
cp ./install/nrc-wizard /usr/local/sbin
cp ./install/nrc-led /usr/local/sbin

cp ./install/nrc-autostart.service /etc/systemd/system/
cp ./install/nrc-led.service /etc/systemd/system/

# refresh systemd to pick up new unit files
systemctl daemon-reload


echo "Done! Run \"systemctl enable nrc-autostart\" to have it run upon boot"
