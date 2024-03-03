# Odysseus
Custom Linux Build being used to drive the TPU

### Current configurations (see below for how to build)
- `raspberrypi4_64_tpu_defconfig` for TPU
    - NRC HaLow station
    - NanoMQ MQTT
    - Calypso CAN decoding
    - GPS support
    - Docker
- `raspberrypi3_64_iroh_defconfig` for off-car charging module
    - Calypso CAN decoding
    - 2.4/5ghz wireless connectivity to base station
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
Download and install to PATH git and docker.  Docker desktop is recommended for macOS and Windows.
```
git clone https://github.com/Northeastern-Electric-Racing/Siren.git
git submodule update --init --recursive
cd ./odysseus
```

For linux (current support includes all build defconfigs):
```
docker compose run --rm --build odysseus # Future launches can omit `--build` for time savings and space savings, but it should be used if the Dockerfile or docker_out_of_tree.sh files change.  

```

For mac and windows: (current support includes all _debug defconfigs, on x86_64 host normal defconfigs can work (experimental)):
```
docker compose -f "compose-compat.yml" run  --rm --build odysseus # Future launches can omit `--build` for time savings and space savings, but it should be used if the Dockerfile or docker_out_of_tree.sh files change.  
```



Now you are in the docker container.  To build cd into the defconfig directory (either ap, or tpu), then run the make command alias:
```
cd ./<defconfig>
make-current
```
You can view the `output.log` for more info.  Now, to deploy just flash the image in `images/

### More on docker configuration
The container has a directory structure as so:
(everything is in `/home/odysseus)
- `./build`
    - `./buildroot`: The buildroot tree 
    - `./odysseus_tree`: The odyssues external tree, bound to the same directory in the git repository on your local machine!
- `./shared_data`: The download and ccache cache for buildroot, should be persisted as long as space is available, there is usually no reason to enter this. A persistent docker volume with the name   `odysseus_shared_data`.
- `./outputs/*`:
    - **The output folders for odysseus.  `cd` into the one named for what defconfig you would like to build, and run the `make` configuration and build commands as described below.  It is recommended to save space to run `make clean` in defconfig directories rather than removing this volume all together. For Linux hosts, this is bound to the `./odysseus/outputs` directory in the repository. For Windows users, this is a docker volume.  *Remember to use `make savedefconfig` when you are done as changes are overriden when you re-open the docker image!*

### Extra docker tips
All paths relative to Siren root.

#### Note for Windows/macOS users
The outputs are stored in a docker volume on these platforms to ensure rsync compatability.  Therefore fetching the files requires first running the image, then use `docker cp` to get them to the userspace.  Alternatively, docker desktop has a file explorer for docker volumes that may come in handy.

#### Writing the sd card
The image is present in `./odysseus/outputs/<defconfig name>/images/sdcard.img`.  One can flash this with tools like the Raspberry Pi OS Imager.

#### Pulling source files for scp, etc.
The target binaries are located in `./odysseus/outputs/<defconfig name>/target`.

#### Cleaning system
`docker image prune --all` (this will not touch volumes)

**IMPORTANT**: this WILL wipe all shared cache (don't do this unless you need the space):  
`docker volume rm odysseus_shared_data`

This will wipe all outputs, not the cache so just requires a full rebuild to recover from.  On compose-compat images only:
`docker volume rm odysseus_outputs`


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
- Build time may be slower due to docker isolations (not dramatic, about 5%)
- Launch time is longer
- Space is used up by rebuilds, prune often or omit `--build`

### Passwords
Root passwords are stored via Github secrets and an encrypted file within a ghcr docker image.  Below are the steps to load and decrypt such passwords for use by buildroot.  Requirements are you know the team's master password and are running x86_64.

1. Authenticate with ghcr.  First make a [classic PAT](https://github.com/settings/tokens/new) with the permission `read:packages`.  Make sure to copy the token, then run `sudo docker login ghcr.io -u <GITHUB_USERNAME> -p <PAT>`
2. cd into odysseus folder and `docker compose pull`
3. Run `docker compose run odysseus` to enter the docker image.  At this point the image should be identical to a locally built one, but it is less preferable for development purposes.
4. Run `load-secrets` and enter the master password.  Consult Odysseus lead if you need this info.  Now your passwords are loaded (can be viewed with `env | grep ODY`), and will be set when you make the sdcard.img.  Note this step must be repeated on each `docker compose run odysseus`, and if the passwords change on Github steps 2 and 3 must be rerun as well.



See below to learn more about developing, and check confluence for most info.  Once in the docker image, all the normal make commands (in an out-of-tree context only) apply.

## Configuring the Project
1. Run ```make menuconfig``` after initializing
2. Make any customizations you want in the menu
3. Save changes after you've made them by running ```make savedefconfig```.  Ensure you are saving changes to the intended defconfig, it is saved to whatever directory you `cd`ed into!

#### Adding defconfigs

Checklist when adding a defconfig:
[ ] Add a secret for SSH password in settings, and load it into the workflow env in `.github/workflows/build_image.yml`
[ ] Add the defconfig itself, changing path names, etc.  Board folders and overlays can still be shared as needed.
[ ] Add a pretty name to `post-build-os-release.sh`
[ ] Add a load command to `setup_env.sh`

<!--
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

### Working with multiple defconfigs simultaneously (default on docker)
Since there are multiple machines this repo deploys to, one can save the build output of multiple defconfigs side-by-side so outputs can be stored easily.  To do this, simply run `make O=my_dir BR2_EXTERNAL=../odysseus_tree <config>` inside the buildroot submodule, where my_dir is a path relative to the buildroot submodule.  Then `cd ./my_dir` and run all make commands from there, and output will be generated into `my_dir`. The `O=` can be omitted as long as your working directory is `my_dir` when running `make`. Make a new directory for each `<config>`, and if you run out of space feel free to `make clean` or delete all the directories (space used about 10 to 22gb).

For example, my system looks like:
- `./buildroot` (each subdir has its own `Makefile`)
    - `./tpu`
    - `./nero`
    - `./ap`
- `./buildroot/dl` (downloads, shared between defconfigs)
- `~/.buildroot-ccache` (shared between defconfigs)
-->
