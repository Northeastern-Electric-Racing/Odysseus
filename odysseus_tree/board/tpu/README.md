Multiple files edited from rpi sources:
<!-- - [bcm2711_tpu_defconfig ](https://github.com/raspberrypi/linux/blob/rpi-6.1.y/arch/arm64/configs/bcm2711_defconfig). Edits include uncompressing modules, spi slave disable. Edit with linux-menuconfig, save with linux-update-**def**config not linux-update-config. Note: fragments not used due to merge being one way (changes are not reflected back out of tree) and not working for in-tree defconfigs. Note: Not exactly like upstream file as buildroot appends toolchain specific changings automatically, this was just a starting point. -->
- <!-- [cmdline.txt](https://github.com/buildroot/buildroot/blob/master/board/raspberrypi/cmdline.txt). Edits include changing serial console.  Edit manually. -->
- [config.txt](https://github.com/buildroot/buildroot/blob/master/board/raspberrypi/config_4_64bit.txt). Edits include adding overlays, changing spi, enabling uart. Edit manually.
<!-- - busybox.config. No deduplication for busybox config, so edits obscured. Current edits include disabling module compression. Edit with make busybox-menuconfig and make busybox-update-config. -->


