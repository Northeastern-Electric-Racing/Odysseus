#!/bin/bash

# for each defconfig make output subdirectory
cd /home/odysseus/build/buildroot
make O=/home/odysseus/outputs/tpu BR2_EXTERNAL=/home/odysseus/build/odysseus_tree raspberrypi4_64_tpu_defconfig
make O=/home/odysseus/outputs/ap BR2_EXTERNAL=/home/odysseus/build/odysseus_tree raspberrypi3_64_ap_defconfig
make O=/home/odysseus/outputs/iroh BR2_EXTERNAL=/home/odysseus/build/odysseus_tree raspberrypi3_64_iroh_defconfig