#!/bin/sh

# STATION MODE led script for ALFA AHPI7292 w/ active-backup bonding indication
######################
# amount of time to wait in between loops
SLEEP_TIME=1
# backup interface in bond
BACKUP_INTERFACE_NAME=wlan0
# primary interface in bond
PRIMARY_INTERFACE_NAME=wlan1
# path to NRC cli app
CLI_APP="/usr/bin/cli_app"
######################

# bit flipper for blinking function
oscillate=0

# set the correct pin directions, must run before a write
$CLI_APP gpio direction 3 1
$CLI_APP gpio direction 2 1

# pin 3 = red led (RX)
# pin 2 = yellow led (TX)

# a cleanup script run upon any exit (like ctrl^c), to turn the lights off and not leave them on and unresponsive.  Should run before module is unloaded.
trap cleanup INT HUP TERM
cleanup() {
    $CLI_APP gpio write 3 0
    $CLI_APP gpio write 2 0
    exit
}

echo "Starting STATION Mode LEDs"
while true;
do
    sleep "$SLEEP_TIME"s

    status_bond=$(ip -json -details link show dev bond0)
    

    # if both interfaces are down, warn by short yellow
    if grep -q "DOWN" <(echo "$status_bond" | jq '.[0].operstate')
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 2 "$oscillate" >> /dev/null
        $CLI_APP gpio write 3 0 >> /dev/null
        continue
    fi
        
    # blink red if backup is linked, solid red if currently active
    if grep -q "$BACKUP_INTERFACE_NAME" <(echo "$status_bond" | jq '.[0].linkinfo.info_data.active_slave')
    then 
        $CLI_APP gpio write 3 1 >> /dev/null
    elif grep -q "UP" <(ip -json -details link show dev "$BACKUP_INTERFACE_NAME" | jq '.[0].linkinfo.info_slave_data.mii_status')
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
    else
        $CLI_APP gpio write 3 0 >> /dev/null
    fi
        
    # solid yellow if primary is linked, which implies it must be active
    if grep -q "UP" <(ip -json -details link show dev "$PRIMARY_INTERFACE_NAME" | jq '.[0].linkinfo.info_slave_data.mii_status')
    then
        $CLI_APP gpio write 2 1 >> /dev/null
    else
        $CLI_APP gpio write 2 0 >> /dev/null
    fi
    
done
