#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

# enable serial, but disable login over serial
echo "1. Enabling serial hardware, disabling serial login console"
raspi-config nonint do_serial 2

# enable spi
echo "2. Enabling SPI hardware"
raspi-config nonint do_spi 0

# update and install relevant packages
apt-get update
apt-get upgrade -y
echo "3. Installing necessary packages"
apt-get install -y raspberrypi-bootloader raspberrypi-kernel raspberrypi-kernel-headers iperf3 hostapd dnsmasq git iptables dhcpcd5 wpasupplicant

# disable and mask networkmanager so it cant mess with wpa_supplicant
echo "3b. Masking NetworkManager"
sudo systemctl disable NetworkManager
sudo systemctl mask NetworkManager

# validate/convert dts to dtbo
echo "4. Creating spi-dev disable file"
dtc -I dts -O dtb -o $SCRIPT_DIR/sources/newracom.dtbo $SCRIPT_DIR/sources/newracom.dts
cp $SCRIPT_DIR/sources/newracom.dtbo /boot/overlays/

# if newracom block not present, add dt overlays mandate
echo "5. Blacklisting bt, wifi, custom newracom spidev"
output="$(cat "/boot/config.txt" | grep -F "[newracom]")"
if [ -n "$output" ];
then
    echo "newracom already set"
else
    cp "/boot/config.txt" "/boot/config.txt.backup-$(date +%s)"
    echo "[newracom]
dtoverlay=disable-bt
dtoverlay=disable-wifi
dtoverlay=newracom" >> "/boot/config.txt"
fi

echo "6. Backing up default wpa_supplicant.conf"
mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.unused


echo "7. Enabling i2c, mac80211"
output_i2c="$(cat "/etc/modules" | grep -e "i2c-dev")"
output_mac="$(cat "/etc/modules" | grep -e "mac80211")"
if [ -n "$output_i2c" ] && [ -n "$output_mac" ];
then
    cp "/etc/modules" "/etc/modules.backup-$(date +%s)"
fi

if [ -n "$output_i2c" ];
then
    echo "i2c already set"
else
    echo "i2c-dev" >> "/etc/modules"
fi

if [ -n "$output_mac" ];
then
    echo "mac80211 already set"
else
    echo "mac80211" >> "/etc/modules"
fi

echo "8. Blacklist brcmfmac and brcmutil"
if  [ -f "/etc/modprobe.d/newracom-blacklist.conf" ];
then
    echo "blacklist already exists"
else
    cp $SCRIPT_DIR/sources/newracom-blacklist.conf /etc/modprobe.d/
fi

# this is for the future update.sh script which has hardcoded username pi (yuck)
# ln -s /home/$SUDO_USER /home/pi
# above commented out, requiring username pi for now to ensure compatability

echo "Setup complete, reboot then move on to nrc install"