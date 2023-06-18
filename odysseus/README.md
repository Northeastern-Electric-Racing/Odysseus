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
2. ```cd``` into the ```Odyssey/odysseus/buildroot``` directory
3. Run ```make BR2_EXTERNAL=../odysseus_tree tpu_defconfig```

## Configuring the Project
1. Run ```make menuconfig``` after initializing
2. Make any customizations you want in the menu
3. Save changes after you've made them by running ```make savedefconfig BR2_DEFCONFIG=../odysseus_tree/configs/tpu_defconfig```

## Building the Project
1. Run ```make``` (Note: this can take a few hours on first build, subsequent builds take less time)
2. Navigate to ```buildroot/output``` and flash an SD card with ```sdcard.img``` (I prefer Ubuntu's disk writer since its easy and in GUI, but can use ```dd``` or whatever you prefer)
3. Put SD card into TPU and boot it (easier to verify connected to a monitor)

