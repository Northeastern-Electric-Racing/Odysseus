#!/bin/sh

CLI_APP=/usr/bin/cli_app

# INCOMPLETE: Only really need this to change from the below defualts (note power saving not even on usually)

# RF Conf.
MAX_TXPWR=24       # Maximum TX Power (in dBm)

# PHY Conf.
# Guard Interval ('auto' (adaptive) or 'long'(LGI) or 'short'(SGI))
GUARD_INT=auto


"$CLI_APP" set txpwr limit "$MAX_TXPWR"
iw phy nrc80211 set txpower limit "$((MAX_TXPWR*100))"

#if str(guard_int) != 'auto':
"$CLI_APP" set gi "$GUARD_INT"


# ps_timeout = '3s'     # STA (timeout before going to sleep) (min:1000ms)
# os.system("sudo iwconfig " + interface + " power timeout " + ps_timeout)
