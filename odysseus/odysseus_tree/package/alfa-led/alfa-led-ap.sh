#!/bin/sh

# AP MODE led script for ALFA AHPI7292 w/ router relayed station active-backup bonding indication
######################
# amount of time to wait in between loops
SLEEP_TIME=1
# backup interface in bond
BACKUP_INTERFACE_NAME=wlan0
# primary interface in bond, an ip as its router relayed
PRIMARY_INTERFACE_IP=192.168.100.12
# path to NRC cli app
CLI_APP="/usr/bin/cli_app"
# mac addr prefix of station halow wifi
HALOW_MAC_ADDR=00:c0:ca
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

echo "Starting AP Mode LEDs"
while true;
do
    sleep "$SLEEP_TIME"s

    # check if ping is successful
    is_present=0
    ping -c 1 "$PRIMARY_INTERFACE_IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
         is_present=1
    fi

    # if both interfaces are down, warn by short yellow
    if [ "$is_present" -eq 0 ]
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 2 "$oscillate" >> /dev/null
        $CLI_APP gpio write 3 0 >> /dev/null
        continue
    fi

    is_halow_connected=0
    # blink red if backup is linked, solid red if currently active
    if grep -q "$HALOW_MAC_ADDR" <(hostapd_cli list_sta)
    then
        $CLI_APP gpio write 3 1 >> /dev/null
#    elif [ "$is_present" -eq 1]
#    then
#       oscillate="$((1-oscillate))"
#        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
    else
        $CLI_APP gpio write 3 0 >> /dev/null
    fi

    # solid yellow if primary is linked, which implies it must be active
    if [ "$is_present" -eq 1 ]
    then
        $CLI_APP gpio write 2 1 >> /dev/null
    else
        $CLI_APP gpio write 2 0 >> /dev/null
    fi

done
#!/bin/sh

# AP MODE led script for ALFA AHPI7292 w/ router relayed station active-backup bonding indication
######################
# amount of time to wait in between loops
SLEEP_TIME=1
# backup interface in bond
BACKUP_INTERFACE_NAME=wlan0
# primary interface in bond, an ip as its router relayed
PRIMARY_INTERFACE_IP=192.168.100.12
# path to NRC cli app
CLI_APP="/usr/bin/cli_app"
# mac addr prefix of station halow wifi
HALOW_MAC_ADDR=00:c0:ca
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

echo "Starting AP Mode LEDs"
while true;
do
    sleep "$SLEEP_TIME"s

    # check if ping is successful
    is_present=0
    ping -c 1 "$PRIMARY_INTERFACE_IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
         is_present=1
    fi

    # if both interfaces are down, warn by short yellow
    if [ "$is_present" -eq 0 ]
    then
        oscillate="$((1-oscillate))"
        $CLI_APP gpio write 2 "$oscillate" >> /dev/null
        $CLI_APP gpio write 3 0 >> /dev/null
        continue
    fi

    is_halow_connected=0
    # blink red if backup is linked, solid red if currently active
    if grep -q "$HALOW_MAC_ADDR" <(hostapd_cli list_sta)
    then
        $CLI_APP gpio write 3 1 >> /dev/null
#    elif [ "$is_present" -eq 1]
#    then
#       oscillate="$((1-oscillate))"
#        $CLI_APP gpio write 3 "$oscillate" >> /dev/null
    else
        $CLI_APP gpio write 3 0 >> /dev/null
    fi

    # solid yellow if primary is linked, which implies it must be active
    if [ "$is_present" -eq 1 ]
    then
        $CLI_APP gpio write 2 1 >> /dev/null
    else
        $CLI_APP gpio write 2 0 >> /dev/null
    fi

done
