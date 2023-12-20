#!/bin/sh

python3 "$BR2_EXTERNAL_ODY_TREE_PATH"/utils/build_nrc_params.py 0 "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_tpu/etc/nrc_opts_sta.ini "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_tpu/etc/modprobe.d/nrc.conf
