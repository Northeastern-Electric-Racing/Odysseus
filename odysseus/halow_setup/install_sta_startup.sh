#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

echo "For STA Mode: Installing systemd file and associated commands"
cd ./install/sta || exit

chmod +x ./nrc-led-sta.sh
chmod + ./nrc-wizard-sta.sh

# /usr/local/sbin is standard for user installed scripts, it is in path
cp ./nrc-wizard-sta.sh /usr/local/sbin

cp ./nrc-led-sta.sh /usr/local/sbin

cp ./nrc-autostart-sta.service /etc/systemd/system/

cp ./nrc-led-sta.service /etc/systemd/system/

# refresh systemd to pick up new unit files
systemctl daemon-reload


echo "Done! Run \"systemctl enable nrc-autostart-sta\" to have it run upon boot"
