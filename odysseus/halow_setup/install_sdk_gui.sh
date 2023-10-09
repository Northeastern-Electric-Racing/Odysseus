#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -eq 0 ]; then
  echo "You are not allowed to run this command as root."
  exit 1
fi

# install java as these are java GUI apps
sudo apt-get install default-jre

cd ~
git clone https://github.com/newracom/nrc7292_sdk

sudo cp $SCRIPT_DIR/install/nrc-firmware-flash /usr/local/sbin/
sudo chmod +x /usr/local/sbin/nrc-firmware-flash


sudo cp $SCRIPT_DIR/install/nrc-at-cmd-test /usr/local/sbin
sudo chmod +x /usr/local/sbin/nrc-at-cmd-test

echo "Finished installing scripts"
echo "Remember to run GUI binaries with X11 fowarding or a desktop"
