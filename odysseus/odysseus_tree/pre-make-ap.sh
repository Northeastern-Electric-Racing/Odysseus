#!/bin/sh

python3 "$BR2_EXTERNAL_ODY_TREE_PATH"/utils/build_nrc_params.py 1 "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_ap/etc/nrc_opts_ap.ini "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_ap/etc/modprobe.d/nrc.conf
