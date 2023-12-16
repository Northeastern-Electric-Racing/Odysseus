#!/bin/bash

python $BR2_EXTERNAL_ODY_TREE_PATH/utils/build_nrc_params.py 0 "$BR2_EXTERNAL_ODY_TREE_PATH/overlays/rootfs_overlay_sta/etc/modprobe.d/nrc.conf"
