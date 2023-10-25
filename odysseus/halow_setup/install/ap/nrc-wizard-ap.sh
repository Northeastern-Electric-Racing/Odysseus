#!/bin/bash

# the parameters to pass into stop.py for ap mode
START_PARAMETERS="1 0 US"


if [ "$EUID" -eq 0 ]; then
  echo "You are not allowed to run this command as root."
  exit 1
fi

if [ "$1" == "start" ] || [ "$1" == "start-systemd" ];
then
    python -u "$HOME"/nrc_pkg/script/start.py "$START_PARAMETERS"
elif [ "$1" == "stop" ];
then
    echo "Begin stop.py -----------------"
    python -u "$HOME"/nrc_pkg/script/stop.py
elif [ "$1" == "startup-logs" ];
then 
  # this displays the most recent invocation ID of nrc-autostart and filters the logs by that invocation, otherwise journalctl would display all logs since nrc-autostart was first started.  It also passes in any other parameters given to journalctl.
  
  # pop the first argument off, which is "startup-logs"
  echo "$@"
  shift;
  
  journalctl -u nrc-autostart-ap.service  "$@" -e _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value nrc-autostart-ap.service)"
else
  echo "FOR AP MODE: Run with start|stop|startup-logs to configure start.py/stop.py accordingly, or get logs"
fi