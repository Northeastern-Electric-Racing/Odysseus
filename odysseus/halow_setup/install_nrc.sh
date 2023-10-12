#!/bin/bash

# get the current location of this script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -eq 0 ]; then
  echo "You are not allowed to run this command as root."
  exit 1
fi


echo "Updating sw pkg"
cd ~
git clone https://github.com/newracom/nrc7292_sw_pkg.git
cd nrc7292_sw_pkg/package/evk/sw_pkg
chmod +x update.sh
./update.sh

echo "Building nrc.ko"
cd ~/nrc7292_sw_pkg/package/src/nrc
make

cp -b nrc.ko ~/nrc_pkg/sw/driver

echo "Building cli_app"
cd ~/nrc7292_sw_pkg/package/src/cli_app
make
chmod +x cli_app

cp -b cli_app ~/nrc_pkg/script

# install custom board data file for alfa, see README for source
echo "Adding correct board data for alfa"
cp -b $SCRIPT_DIR/sources/nrc7292_bd.dat ~/nrc_pkg/sw/firmware
