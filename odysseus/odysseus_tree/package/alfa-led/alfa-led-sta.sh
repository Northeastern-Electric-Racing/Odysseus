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
# pin 2 = yellow red (TX)

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
    # check if backup is active
    current_active=$(cat /sys/class/net/bond0/bonding/active_slave)
    
    output_status=$(cat /proc/net/bonding/bond0)
    
    is_conn="0"
    
    # blink red if backup is linked, solid if used
    if [ "$current_active" = "$BACKUP_INTERFACE_NAME" ];
    then 
        $CLI_APP gpio write 3 1 >> /dev/null
    elif grep -q "up" <(echo $output_status | grep -A=1 "Slave Interface: $BACKUP_INTERFACE_NAME")
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
        is_conn="1"
    fi
    
    # blink yellow if primary is linked, solid if used
    if [ "$current_active" = "$PRIMARY_INTERFACE_NAME" ];
    then 
        $CLI_APP gpio write 2 1 >> /dev/null
    elif grep -q "up" <(echo $output_status | grep -A=1 "Slave Interface: $PRIMARY_INTERFACE_NAME")
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 2 "$oscillate" >> /dev/null
        is_conn="1"
    fi
    
    # blink simeltaneously if both unconnected
    if [ "$is_conn" = "1" ];
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
    fi
    
    is_conn="0"
done
