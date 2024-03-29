#!/bin/sh

python3 "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_nrc_common/usr/bin/build_nrc_params.py AP --ini-path "$BR2_EXTERNAL_ODY_TREE_PATH"/overlays/rootfs_overlay_ap/etc/nrc_opts_ap.ini --mod-path "$TARGET_DIR"/etc/modprobe.d/nrc.conf
