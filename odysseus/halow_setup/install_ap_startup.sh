#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

echo "For AP Mode: Installing systemd file and associated commands"
cd ./install/ap/ || exit

chmod +x ./nrc-led-ap.sh
chmod + ./nrc-wizard-ap.sh

# /usr/local/sbin is standard for user installed scripts, it is in path
cp ./nrc-wizard-ap.sh /usr/local/sbin

cp ./nrc-led-ap.sh /usr/local/sbin

cp ./nrc-autostart-ap.service /etc/systemd/system

cp ./nrc-led-ap.service /etc/systemd/system/

# refresh systemd to pick up new unit files
systemctl daemon-reload


echo "Done! Run \"systemctl enable nrc-autostart-ap\" to have it run upon boot"