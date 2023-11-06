#!/bin/bash

GPSD_VERSION=3.25

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

# how to build: https://gpsd.io/building.html
apt install pps-tools scons python3-serial python3-distutils libncurses-dev build-essential manpages-dev pkg-config chrony

# for xgps and gpsplot: libgtk-3-dev python3-gi python3-gi-cairo python3-matplotlib

if [ -d "./gpsd-$GPSD_VERSION" ];
then
  echo "Note, using the pre-downloaded gpsd version $GPSD_VERSION"
  echo "Delete the ./gpsd-$GPSD_VERSION directory to redownload GPSD source"
else
  # dl new source
  echo "Downloading source code version $GPSD_VERSION"
  wget http://download.savannah.gnu.org/releases/gpsd/gpsd-"$GPSD_VERSION".tar.gz
  tar -xzf gpsd-"$GPSD_VERSION".tar.gz
fi
cd gpsd-"$GPSD_VERSION" || exit

# required for various helper tools
export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3/dist-packages

# build, check, install only if the preceeding command works
scons && scons check && scons udev-install

echo "If the above processes completed, without error, assume gpsd was installed correctly."
echo "If there was an error, gpsd probably never got installed!  
Override this by running scons udev-install in the gpsd source folder."







