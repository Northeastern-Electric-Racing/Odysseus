#!/bin/bash

PPS_GPIO_PIN=18
UART_DEV_FILENAME=/dev/ttyAMA0


if [ "$EUID" -ne 0 ]; then
  echo "You are not root, exiting."
  exit 1
fi

# add the new gpsd file pointing to correct UART and GPIO locations
cp "/etc/default/gpsd" "/etc/default/gpsd.backup-$(date +%s)"
echo "# custom replaced gpsd configuration script

# devices are ACM0 for UART and pps0 for pps-gpio
DEVICES=\"$UART_DEV_FILENAME /dev/pps0\"

# ensure GPSD properly exits
GPSD_OPTIONS=\"-n\" 
" > "/etc/default/gpsd"


# add the pps line to the dt overlay
output="$(grep -F "[pps-gpio]" < "/boot/config.txt")"
if [ -n "$output" ];
then
    echo "pps-gpio already set"
else
    cp "/boot/config.txt" "/boot/config.txt.backup-$(date +%s)"
    echo "[pps-gpio]
dtoverlay=pps-gpio,gpiopin=$PPS_GPIO_PIN" >> "/boot/config.txt"
fi

# add pythonpath to bash
output="$(grep -F "export PYTHONPATH=\${PYTHONPATH}:/usr/local/lib/python3/dist-packages" < "/home/pi/.bashrc")"
if [ -n "$output" ];
then
    echo "Bash export already configured"
else
    echo "export PYTHONPATH=\${PYTHONPATH}:/usr/local/lib/python3/dist-packages" >> "/home/pi/.bashrc"
fi


echo "Setup complete"