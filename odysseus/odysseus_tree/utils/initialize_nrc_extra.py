#!/usr/bin/python


# INCOMPLETE: Only really need this to change from the below defualts (note power saving not even on usually)

import od

# RF Conf.
max_txpwr = 24       # Maximum TX Power (in dBm)

# PHY Conf.
# Guard Interval ('auto' (adaptive) or 'long'(LGI) or 'short'(SGI))
guard_int = 'auto'

ps_timeout = '3s'     # STA (timeout before going to sleep) (min:1000ms)


os.system('/usr/bin/cli_app set txpwr limit ' + str(max_txpwr))
os.system('sudo iw phy nrc80211 set txpower limit ' +
          str(int(max_txpwr) * 100))

if str(guard_int) != 'auto':
    os.system('/usr/bin/cli_app set gi ' + guard_int)

os.system("sudo iwconfig " + interface + " power timeout " + ps_timeout)
