#!/bin/bash

# this scripts installs and configures mosquitto for a debian-based linux system

MOSQUITTO_VERSION="2.0.11"

# logs: /var/log/mosquitto
# systemd file: mosquitto
# conf include: conf.d/siren.conf

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi


# install mosquitto
echo "Installing mosquitto"

apt update && apt upgrade
apt install mosquitto

# clone and make the message-timestamp file
echo "Building and installing timestamping plugin"
git clone --depth 1 --branch v$MOSQUITTO_VERSION https://github.com/eclipse/mosquitto /tmp/mosquitto
cd "/tmp/mosquitto/plugins/message-timestamp" || exit
make

# add the plugin to arch specific folder
ARCH=$(uname -m)
cp "./mosquitto_message_timestamp.so" "/usr/lib/$ARCH-linux-gnu/mosquitto_message_timestamp.so"



# add a conf file to load the plugin
echo "plugin /usr/lib/$ARCH-linux-gnu/mosquitto_message_timestamp.so" > "/etc/mosquitto/conf.d/plugins.conf"

./conf_update_pi.sh



