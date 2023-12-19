#!/bin/bash

# the parameters to pass into start.py for sta mode
START_PARAMETERS=(0 0 US)
# check every x seconds if the nrc system has booted
SLEEP_TIME=1


if [ "$EUID" -eq 0 ]; then
  echo "You are not allowed to run this command as root."
  exit 1
fi

if [ "$1" == "start" ];
then
    python -u "$HOME"/nrc_pkg/script/start.py "${START_PARAMETERS[@]}"
elif [ "$1" == "start-systemd" ];
then
    echo "Begin start.py ----------------"
    python -u "$HOME"/nrc_pkg/script/start.py "${START_PARAMETERS[@]}" &
    # capture start.py pid
    start_pid="$!"
    while true;
    do
      sleep $SLEEP_TIME
      # get the latest string in startup-logs beginining in [DIGIT]
      # example : [7] Connect and DHCP
      latest=$(/usr/local/sbin/nrc-wizard-sta.sh startup-logs | grep -o -P "\[\d\].*" | tail -n 1)
    
      # update system status with latest message
      systemd-notify --status="Currently on $latest"
    
      # if latest is 7 or 8, tell systemd startup is complete, and break the loop to sleep for infinity
      if [[ $latest =~ \[7\].* || $latest =~ \[8\].* ]];
      then
          systemd-notify --ready
          break
      elif ! [ -d "/proc/$start_pid" ]; # if start.py has finished running
      then # refresh status message and exit the script, telling systemd to shutdown and cleanup
          latest=$(/usr/local/sbin/nrc-wizard-sta.sh startup-logs | grep -o -P "\[\d\].*" | tail -n 1)
    
          # update system status with latest message
          systemd-notify --status="Failed on $latest"
          exit 1
      fi

    done
    
    sleep infinity
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
  
  journalctl -u nrc-autostart-sta.service  "$@" -e _SYSTEMD_INVOCATION_ID="$(systemctl show -p InvocationID --value nrc-autostart-sta.service)"
else
  echo "FOR STA MODE: Run with start|stop|startup-logs to configure start.py/stop.py accordingly, or get logs"
fi