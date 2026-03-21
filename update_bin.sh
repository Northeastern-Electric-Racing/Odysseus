#!/bin/bash

# 1: The name of the device ("wheel","iroh", or "tpu")
# 2: The name of the package to update ("calypso", "odysseus-daemon", or "nero")
# 3: The root password of the device
# 4: The commit sha (only if calypso or odysseus-daemon)

def_path=""
ip_addr=""
if [ "$1" == "wheel" ]; then
   def_path="wheel-cm5"
   ip_addr="192.168.100.14"
elif [ "$1" == "tpu" ]; then
   def_path="tpu-cm5"
   ip_addr="192.168.100.12"
elif [ "$1" == "iroh" ]; then
   def_path="iroh"
   ip_addr="192.168.100.13"
else
   echo "Not a valid device!"
   exit 1
fi

# 1: The name of the package in buildroot
update_pkg_br() {
   docker_hash=$(docker compose run -d --rm odysseus)
   docker exec "$docker_hash" sh -c "make -C /home/odysseus/outputs/$def_path $1-reconfigure"
   docker stop "$docker_hash"
}

# 1: The root password of the TPU
# 2: The name of the initscript to stop on the target
# 3: The path to the binary local to send to target
# 4: The path to put on target
refresh_local() {
   sshpass -p "$1" ssh root@$ip_addr -t "/etc/init.d/$2 stop"
   sshpass -p "$1" scp "$3" "root@$ip_addr:$4"
   sshpass -p "$1" ssh root@$ip_addr -t "/etc/init.d/$2 start"
}


if [ "$2" == "calypso" ]; then
   echo "Updating Calypso"
   sed -i "1 s/.*/CALYPSO_VERSION = $4/" ./odysseus_tree/package/calypso/calypso.mk
   update_pkg_br "calypso"
   refresh_local "$3" "S76calypso" "./outputs/$def_path/per-package/calypso/target/usr/bin/calypso" "/usr/bin/calypso"
   sshpass -p "$2" scp "./outputs/$def_path/per-package/calypso/target/usr/bin/nerimd" "root@192.168.100.12:/usr/bin/nerimd"
elif [ "$2" == "odysseus-daemon" ]; then
   echo "Updating odysseus-daemon"
   sed -i "1 s/.*/ODYSSEUS_DAEMON_VERSION = $4/" ./odysseus_tree/package/odysseus-daemon/odysseus-daemon.mk
   update_pkg_br "odysseus-daemon"
   refresh_local "$3" "S99odysseus-daemon" "./outputs/$def_path/per-package/odysseus-daemon/target/usr/bin/odysseus-daemon" "/usr/bin/odysseus-daemon"
   # also add the cli uploader binary, which doesnt run all the time
   sshpass -p "$3" scp "./outputs/$def_path/per-package/odysseus-daemon/target/usr/bin/odysseus-uploader" "root@$ip_addr:/usr/bin/odysseus-uploader"
elif [ "$2" == "nero" ]; then
   echo "Updating NERO"
   update_pkg_br "nero2"
   refresh_local "$3" "S99nero2" "./outputs/$def_path/per-package/nero2/target/usr/bin/NEROApp" "/usr/bin/NEROApp"
else
   echo "Not a valid project to update"
fi
