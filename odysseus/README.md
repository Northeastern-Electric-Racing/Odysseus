# Odysseus
Custom Linux Build being used to drive the TPU

### Current configurations (see below for how to build)
- `raspberrypi4_64_tpu_defconfig` for TPU
    - NRC HaLow station
    - NanoMQ MQTT
    - Calypso CAN decoding
    - GPS support
    - Docker
    - Nero display abilities
- `raspberrypi3_64_ap_defconfig` for base station HaLow access point
    - NRC HaLow access point

All defconfigs come with (in addition to busybox and util_linux utilities):

- SSH server/client (and scp client)
- SFTP server (scp server support)
- htop
- bmon
- fsck
- python3
- GPIO read/write utilities
- dtoverlay support
- iperf3, iw, iputils, and other network configuration utilities

## Quick start
Download and install to PATH git and docker.
```
git clone https://github.com/Northeastern-Electric-Racing/Siren.git
git checkout develop-initial-hw-validation
git submodule update --init -recursive
cd ./odysseus
docker compose run --rm --build odysseus # Future launches can omit `--build` for time savings and space savings, but it should be used if the Dockerfile or docker_out_of_tree.sh files change.  
```
Now you are in the docker container.  To build cd into the defconfig directory (either ap, or tpu), then run the make command alias:
```
cd ./<defconfig>
make-current
```
You can view the `output.log` for more info.

### More on docker configuration
The container has a directory structure as so:
(everything is in `/home/odysseus)
- `./build`
    - `./buildroot`: The buildroot tree 
    - `./odysseus_tree`: The odyssues external tree, bound to the same directory in the git repository on your local machine!
- `./shared_data`: The download and ccache cache for buildroot, should be persisted as long as space is available, there is usually no reason to enter this. A persistent docker volume with the name   `odysseus_shared_data`.
- `./outputs/*`:
    - **The output folders for odysseus.  `cd` into the one named for what defconfig you would like to build, and run the `make` configuration and build commands as described below.  It is recommended to save space to run `make clean` in defconfig directories rather than removing this volume all together. This is bound to the `./odysseus/outputs` directory in the repository. *Remember to use `make savedefconfig` when you are done as changes are overriden when you re-open the docker image!*

### Extra docker tips
All paths relative to Siren root.

#### Writing the sd card
The image is present in `./odysseus/outputs/<defconfig name>/images/sdcard.img`.

#### Pulling source files for scp, etc.
The target binaries are located in `./odysseus/outputs/<defconfig name>/target`.

#### Cleaning system
`docker image prune --all` (this will not touch volumes)

**IMPORTANT**: this WILL wipe all shared cache (don't do this unless you need the space):  
`docker volume rm odysseus_shared_data`

#### Open another tty
`docker ps`
Find the container ID of odysseus-odysseus then run:  
`docker exec -it <container_id> bash` 

#### Run in background
One can still build, but in the background.  This can be done by using docker-compose with `-d` and running docker exec like so:
```
docker exec <container_id> -d -w /home/odysseus/outputs/<defconfig> make-current`
```
Be careful with this.
    
Docker limitations:
- Build time may be slower due to docker isolations (not dramatic, about 5-15%)
- Launch time is longer
- Space is used up by rebuilds, prune often or omit `--build`

### Passwords
In order to change ssh/root passwords for each defconfig, copy `./odysseus/SECRETS.env-example` to `./odysseus/SECRETS.env` and edit it as needed. **Do not move, rename, or otherwise commit that file in any way after you have edited, as it contains sensitive info**.  Make sure to restart the docker image after editing the file.



Skip down to "Configuring the project" to learn more about developing, and check confluence for most info.  Once in the docker image, all the normal make commands (in an out-of-tree context only) apply.




## Build locally
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

    
### Initializing the Project
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
2. Run ```make -j$(nproc) --output-sync=target``` (Note: this can take a few hours on first build, subsequent builds take less time).  Lower the -jN number to use less cores of your CPU to make your system usable during the build, at the expense of time.
3. Navigate to ```buildroot/output``` and flash an SD card with ```sdcard.img``` (I prefer Ubuntu's disk writer since its easy and in GUI, but can use ```dd``` or whatever you prefer)
4. Put SD card into TPU or AP and boot it.  Connection via HDMI to ensure it works, as well as serial pins (baud rate 115200), or ethernet hardwired to your computer with your computer in network sharing mode (note AP has a static eth0 address so it would be difficult to hard wire).

### Working with multiple defconfigs simultaneously (default on docker)
Since there are multiple machines this repo deploys to, one can save the build output of multiple defconfigs side-by-side so outputs can be stored easily.  To do this, simply run `make O=my_dir BR2_EXTERNAL=../odysseus_tree <config>` inside the buildroot submodule, where my_dir is a path relative to the buildroot submodule.  Then `cd ./my_dir` and run all make commands from there, and output will be generated into `my_dir`. The `O=` can be omitted as long as your working directory is `my_dir` when running `make`. Make a new directory for each `<config>`, and if you run out of space feel free to `make clean` or delete all the directories (space used about 10 to 22gb).

For example, my system looks like:
- `./buildroot` (each subdir has its own `Makefile`)
    - `./tpu`
    - `./nero`
    - `./ap`
- `./buildroot/dl` (downloads, shared between defconfigs)
- `~/.buildroot-ccache` (shared between defconfigs)
