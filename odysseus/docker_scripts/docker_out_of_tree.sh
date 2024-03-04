#!/bin/bash
                                                                                                                                      
alias make-current="/home/odysseus/scripts/make-current.sh"

# for each defconfig make output subdirectory
make -C /home/odysseus/build/buildroot O=/home/odysseus/outputs/tpu BR2_EXTERNAL=/home/odysseus/build/odysseus_tree raspberrypi4_64_tpu_defconfig
make -C /home/odysseus/build/buildroot O=/home/odysseus/outputs/ap BR2_EXTERNAL=/home/odysseus/build/odysseus_tree raspberrypi3_64_ap_defconfig


echo \
    "
    ██████  ██████  ██    ██ ███████ ███████ ███████ ██    ██ ███████
   ██    ██ ██   ██  ██  ██  ██      ██      ██      ██    ██ ██     
   ██    ██ ██   ██   ████   ███████ ███████ █████   ██    ██ ███████
   ██    ██ ██   ██    ██         ██      ██ ██      ██    ██      ██
    ██████  ██████     ██    ███████ ███████ ███████  ██████  ███████"
