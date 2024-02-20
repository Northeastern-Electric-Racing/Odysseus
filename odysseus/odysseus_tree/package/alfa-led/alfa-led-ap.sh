#!/bin/sh

######################
# amount of time (in seconds) to wait in between loops
SLEEP_TIME=1.5
#ap interface, wlan0 for default newracom configuration
INTERFACE_NAME=wlan0
# the ethernet interface to check if an ip addr has been attained, for yellow light
YELLOW_LED_INTERFACE_NAME=eth0
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

echo "Starting ACCESS POINT Mode LEDs"
while true;
do
    sleep "$SLEEP_TIME"s
    # see list of connected clients (if non empty)
    # check gateway for ip being given
    clients_present=$(hostapd_cli list_sta -i $INTERFACE_NAME)
    if [ -n "$clients_present" ];
    then
        $CLI_APP gpio write 3 1 >> /dev/null
    else
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
    fi

    ip -json address show "$YELLOW_LED_INTERFACE_NAME" | jq -e '.[0].addr_info' >> /dev/null
    if [ "$?" -ne 0 ];
    then
        $CLI_APP gpio write 2 1 >> /dev/null
    else
        $CLI_APP gpio write 2 0 >> /dev/null
    fi
done
