# Odysseus
Custom Linux Build being used to drive the TPU

### Current configurations (see below for how to build)
- `raspberrypi4_64_tpu_defconfig` for TPU
    - NRC HaLow station
    - NanoMQ MQTT
    - Calypso CAN decoding (TBD)
    - GPS support
    - Docker
- `raspberrypi3_64_ap_defconfig` for base station HaLow access point
    - NRC HaLow access point
- `raspberrypi4_64_nero_defconfig` for in-car dashboard
    - 2.4 Ghz integrated access point (TBD)
    - NanoMQ MQTT
    - Calypso CAN decoding (TBD)


All defconfigs come with (in addition to busybox and util_linux utilities):

- SSH server/client (and scp client)
- SFTP server (scp server support)
- htop
- bmon
- python3
- GPIO read/write utilities
- dtoverlay support
- iperf3, iw, iputils, and other network configuration utilities


## Setting up Docker Environment
TBD, for now build locally on Linux

## Setting up loal environment
1. Install `git-lfs` (for nanomq submodules)
2. Install all buildroot dependencies, including:
    - [All mandatory packages](https://buildroot.org/downloads/manual/manual.html#requirement) (most preinstalled on a normal linux system)
    - python3
    - libxcrypt or glibc with libcrypt enabled (libcrypt-dev in ubuntu/focal or debian bullseye).  If you encounter the error below in the `Finalizing target directory` phase, you may need to install a legacy version of libxcrypt that supports sha-256.  If the package fails at `crypt.h not found`, you need to install at least one of the above packages.
    ```
    /usr/bin/sed -i -e s,^root:[^:]*:,root:"`/home/jack/Projects/NER/buildroot/Siren/odysseus/buildroot/output/host/bin/mkpasswd -m "sha-256" "password"`":, /home/jack/Projects/NER/buildroot/Siren/odysseus/buildroot/output/target/etc/shadow
    crypt failed
    ```
    - ncurses5 (or 6) (for menuconfig)
    - Git, rsync
    - graphviz, python-matplotlib, and dotx for graph creation (optional)

<!-- ## Start Container on MacOS/Linux
In any terminal that is in the directory:

    # if need to rebuild image
    docker image prune -a
    sudo docker build -f ./Dockerfile -t ner-gcc-arm .

    sudo docker run --rm -it --privileged -v "$PWD:/home/app" ner-gcc-arm:latest bash -->
    
## Initializing the Project
1. Run ```git submodule update --init``` to clone the buildroot repo locally
2. Optional: Edit `./Siren/odysseus/odysseus_tree/configs/raspberrypi4_64_tpu_defconfig` and `./Siren/odysseus/odysseus_tree/configs/raspberrypi4_64_tpu_defconfig`; in both files change `BR2_CCACHE_DIR=` to a directory prepared to hold around ~5G of data.
3. ```cd``` into the ```Siren/odysseus/buildroot``` directory
4. Run ```make BR2_EXTERNAL=../odysseus_tree <config>``` supplanting `<config>` with either `raspberrypi4_64_tpu_defconfig` for TPU deployment or `raspberrypi3_64_ap_defconfig` for the base station access point deployment.
5. All future config loads can omit BR2_EXTERNAL.

## Configuring the Project
1. Run ```make menuconfig``` after initializing
2. Make any customizations you want in the menu
3. Save changes after you've made them by running ```make savedefconfig```.  Ensure you are saving changes to the intended defconfig, it is the defconfig you originally loaded!

## Building the Project
1. Run `make <config>` using the config you want to build (see above), note that any `menuconfig` changes are overwritten with this command.
2. Run ```make -j$(($(nproc)+1)) --output-sync=target``` (Note: this can take a few hours on first build, subsequent builds take less time).  Lower the -jN number to use less cores of your CPU to make your system usable during the build, at the expense of time.
3. Navigate to ```buildroot/output``` and flash an SD card with ```sdcard.img``` (I prefer Ubuntu's disk writer since its easy and in GUI, but can use ```dd``` or whatever you prefer)
4. Put SD card into TPU or AP and boot it.  Connection via HDMI to ensure it works, as well as serial pins (baud rate 115200), or ethernet hardwired to your computer with your computer in network sharing mode (note AP has a static eth0 address so it would be difficult to hard wire).

### Working with multiple defconfigs simultaneously
Since there are multiple machines this repo deploys to, one can save the build output of multiple defconfigs side-by-side so outputs can be stored easily.  To do this, simply run `make O=my_dir BR2_EXTERNAL=../odysseus_tree <config>` inside the buildroot submodule, where my_dir is a path relative to the buildroot submodule.  Then `cd ./my_dir` and run all make commands from there, and output will be generated into `my_dir`. The `O=` can be omitted as long as your working directory is `my_dir` when running `make`. Make a new directory for each `<config>`, and if you run out of space feel free to `make clean` or delete all the directories (space used about 10 to 22gb).

For example, my system looks like:
- `./buildroot` (each subdir has its own `Makefile`)
    - `./tpu`
    - `./nero`
    - `./ap`
- `./buildroot/dl` (downloads, shared between defconfigs)
- `~/.buildroot-ccache` (shared between defconfigs)

STA Networking:
- interfaces file brings up eth0, wlan0, calls wpa_supplicant with correct config file for wlan0
- dhcpcd listens/probes for addresses on eth0 + wlan0 while wpa_supplicant attempts to connect to an access point

AP Networking:
- interfaces file brings up eth0, bridges it to br0
- hostapd brings up wlan0 and bridges it it br0
- dhcpcd sets static IP addresses for AP on both eth0 and wlan0.
