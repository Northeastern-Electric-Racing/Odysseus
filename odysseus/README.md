# Odysseus
Custom Linux Build being used to drive the TPU

## Setting up Docker Environment
TBD, for now build locally on Linux

## Start Container on MacOS/Linux
In any terminal that is in the directory:

    # if need to rebuild image
    docker image prune -a
    sudo docker build -f ./Dockerfile -t ner-gcc-arm .

    sudo docker run --rm -it --privileged -v "$PWD:/home/app" ner-gcc-arm:latest bash
    
## Initializing the Project
1. Run ```git submodule update --init``` to clone the buildroot repo locally
2. Edit `./Siren/odysseus/odysseus_tree/configs/raspberrypi4_64_tpu_defconfig` and change `BR2_CCACHE_DIR=` to a directory prepared to hold around ~5G of data.
3. ```cd``` into the ```Siren/odysseus/buildroot``` directory
4. Run ```make BR2_EXTERNAL=../odysseus_tree/raspberrypi4_64_tpu_defconfig```
5. All future config loads should be easier: `make raspberrypi4_64_tpu_defconfig`

## Configuring the Project
1. Run ```make menuconfig``` after initializing
2. Make any customizations you want in the menu
3. Save changes after you've made them by running ```make savedefconfig```

## Building the Project
1. Run ```make``` (Note: this can take a few hours on first build, subsequent builds take less time)
2. Navigate to ```buildroot/output``` and flash an SD card with ```sdcard.img``` (I prefer Ubuntu's disk writer since its easy and in GUI, but can use ```dd``` or whatever you prefer)
3. Put SD card into TPU and boot it.  Connection via HDMI to monitor works, as well as serial pins (baud rate 115200), or ethernet hardwired to your computer with your computer in network sharing mode.

STA Networking:  
- interfaces file brings up eth0, wlan0, calls wpa_supplicant with correct config file for wlan0
- dhcpcd listens/probes for addresses on eth0 + wlan0 while wpa_supplicant attempts to connect to an access point
