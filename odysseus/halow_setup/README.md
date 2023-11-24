This is the complete process to get Halow wifi working as a station in host mode.  Other modes and AP configuration may work with manual customization.

#### Made for newracom version 1.4.1


Required equipment:
- Developer computer is **linux** (Ubuntu works fine) with...
    - SSH insalled: on Ubuntu its package `openssh-client` (so `apt install openssh-client`), so you can SSH into the pi
    - An internet connection: so the pi can recieve that connection, as the pi cannot network after step 1 of this guide!
    - A way to ethernet connect to the pi (adapters work)
    - A way to write to a microSD card
- Raspberry Pi 4 SBC (the Pi 3 can work but requires different overlay files, not covered here)
- A minimun 16 gb microSD card
- Halow hat: ALFA AHPI7292S RevB or greater (for UART select) in HOST mode ([read "How to switch modes"](https://docs.alfa.com.tw/Product/AHPI7292S/30_Technical_Details/))

# Setup Pi

### Image

1. Download, install, and open: [Rpi Imager](https://www.raspberrypi.com/software/)
2. Choose OS: Pi OS other > Raspberry OS lite (64-bit) Debian Bookworm
3. Choose Storage: micro-sdcard (note on Linux an external adapter is needed for laptop connection of microSD cards, or the card will not show up in the list)
4. Settings: Enable SSH, set username "pi" and password "Racecar202". **Dont configure wifi or change username**
5. Write and wait for completion

### Connect
Boot up the pi, and connect ethernet between pi and linux computer.  Wait a solid 2-3 minutes as the first boot takes a considerable amount of time partitioning.

On computer's network management GUI:
1. Open the list of network connections (not the tray applet)
2. With the pi powered on and ethernet connected, wait until "wired connection" or "enps..." or "eth0" appears
3. Click the plus and create a "wired connection (shared)", then press connect.  Wait like 30 seconds.
4. Open a terminal and use `arp -a` to get the pi ip (it is the number that is higher than the "gateway" but still in the same range as it).  Wait until the command shows the MAC address instead of `<incomplete>`.  Ssh into rpi with above ip and correct username/password (`ssh pi@<IP>`).

On CLI only: (TODO)

Next, run `ping 8.8.8.8` to ensure the internet connection your computer has is being shared to the pi.  If it is working you will see a repetitive output and nothing along the lines of `unreachable` or `timed out`.

### Download scripts
The following command line items are run inside the pi terminal.  If you reboot or otherwise lose connection, ensure these commands are being run in `pi@<IP>` NOT your own linux install.  
`sudo apt install git`  
`git clone https://github.com/Northeastern-Electric-Racing/Siren.git`  
`mv ~/Siren/odysseus/halow_setup ~/`  
`sudo reboot now`  

# Install and Configure NRC

### Setup system
`cd ~/halow_setup`  
`sudo ./setup_system.sh`  
`sudo reboot now`  

### Install NRC
`cd ~/halow_setup`  
`./install_nrc.sh`  
`sudo reboot now`

### Configure connection
`cd ~/nrc_pkg/script/conf/US/`

open `sta_halow_open.conf` and edit in the `network={}`

- `ssid=SilexAH` (or SSID of another AP)
- `scan_ssid=1`
- `scan_freq= <channel>`
- `freq_list= <channel>`

See channels [here](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-003-S1G_Channel.pdf), use the 2.4/5 ghz codes as linux doesn't understand sub-ghz.  Can use multiple channels by space-seperating the channel numbers.  **Ensure the AP is set to the correct channel!**  Optionally do not set this, and it will scan all channels to find the AP at ssid.

## Setup shortcuts and autostart
`cd ~/halow_setup`  
`sudo ./install_startup_script.sh`  

If you would like to autostart the script:  
`sudo systemctl enable nrc-autostart.service`  
When using the systemd service, use the shortcut `nrc-wizard.sh startup-logs` to get the most recent invocation of nrc-autostart and what it prints out.  Note: any parameters past startup-logs will get piped into journalctl (one useful one is `-f` to live-reload the log).

Upon using the systemd unit, `nrc-led.service` is also run to allow for LED behaviors.  Manual `nrc-led.sh` usage is not recommended as it is not aware of nrc status and can just write a bunch of errors to gpio.  
Current LED behavior:  
Red light --> blinking: on no IP; solid: on IP recieved  
Yellow light --> solid: pinged 8.8.8.8 successfully  

See [below](#change-configuration-and-other-fs-locations) for how to change such behavior.

# Use NRC manually
Start manually:  
`nrc-wizard.sh start`

Stop manually (recommended be run on every shutdown or after Ctrl^C of start, no matter what!):  
`nrc-wizard.sh stop`

Scan for APs:  
`iwlist wlan0 scan`

### For firmware flashing and test guis (not needed)
setup X11Foward in ssh config (on pi):  
edit /etc/ssh/sshd_config, and uncomment + change:

 - X11Forwarding yes
 - X11DisplayOffset 10

`sudo apt install xauth`  
`sudo systemctl restart sshd`  

On computer connect with -X (only use when needed, sometimes makes networking insanely slow!):

`ssh -X pi@<IP>`  
`cd ~/halow_setup/`  
`./install_sdk_gui.sh`

Usage:

`nrc-firmware-flash.sh` --> Flashes firmware in DOWNLOAD mode, probably never needed for HOST mode  
`nrc-at-cmd-test.sh` -->  ?  TODO: figure out what that does  
[Documentation here](https://github.com/newracom/nrc7292_sdk/tree/master/package/standalone/tools/external/docs)


# Sources and more info
Important: all scripts not home relative at the moment, **so user must be pi**


### Change configuration and other FS locations
There are many sources of configuration change, some not outlined above.  **All files meant to be edited to change configurations are in bold**

 - /home/pi/nrc_pkg/script/ -->
     - **start.py** (sets up all driver + networking, used by nrc-wizard.sh script), [see the google doc with info regarding module settings of interest to edit](https://docs.google.com/document/d/1o79gr1qESW38YnxxlvXTVY8_S3Yupzfv_w48i5PA4q4/edit?usp=sharing)
     - stop.py (stops driver and associated process, used by nrc-wizard.sh script)
     - cli_app (communicates with driver to show, configure, and debug various aspects of halow) [see below for usage](#documentation-of-setup)
     - **conf/US/sta_halow_open.conf** (a wpa_supplicant.conf file loaded when STA mode without security is run in US country (0 0 US)), see [here](http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf) for all possible parameters.  Parameters of note are outlined [above](#configure-connection)
 - /usr/local/sbin (in $PATH) -->
     - **nrc-wizard.sh** (runs start and stop on systemd), edit START_PARAMETERS at the top of the file in order to change the configuration passed into start.py, including STA/AP, security, and country.  Default is `0 0 US`
     - nrc-firmware-flash (download mode GUI firmware flash tool)
     - nrc-at-cmd-test (GUI scan networks, etc.)
     - **nrc-led.sh** (runs LED driver *only works automatically via systemd*), edit the paramters at the top of the file to change LED behavior

## Documentation of setup

All documentation and bash scripts were made from [newracom documentation](https://github.com/newracom/nrc7292_sw_pkg/tree/master/package/doc), mainly:
 - configuring the system and installing nrc: [the pi setup guide](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-018-Raspberry_Pi_setup.pdf)
 - configuring connection and driver usage: [EVK user guide host mode](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-001-EVK%20User%20Guide%20\(Host%20Mode\).pdf)
 - channel listings: [Channel Sub-1G](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-003-S1G_Channel.pdf)
 - cli_app usage (see above): [CLI application](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-007-Commnad%20line%20application.pdf).  Helpful show commands:
 
     - `show uinfo 0` (see AP/STA info)
     - `show confing 0` (see driver configuration)
     - `show ap 0` (see AP tx/rx)
     - `show signal [start|stop] [interval] [number]` (see signal strength, usage in PDF)
     - `show optimal_channel <Country> <BW> <dwell time>` (reduces scan time by optimizing channel?)
     - `show sysconfig` (get MAC of board, and other info)
     

### Sources (see below for usage)
Note that everything in the `./sources` directory is from ALFA or newracom, and everything in the `./install` directory is made custom for NER convenience.

 - nrc7292_bd.dat --> [newracom made this for ALFA](https://github.com/newracom/nrc7292_sw_pkg/issues/60).  Replaces the preinstalled board data file at `nrc_pkg/sw/firmware` in the script `install_nrc.sh`.

    The actual process by which this file was made is not definite, all documentation [here](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-015-Transmit_Power_Control.pdf).  A GUI tool to make board data files was moved in 1.3.4, changelogs do not allude to why. **A newracom update could break ALFA compatability**, and ALFA has not updated their file since 1.3.4 rev2, and it does not work in 1.4.1 due to newracom breaking changes.  TODO: come up with a way to compile the above file and/or find the BoardDataEditor.exe.

 - newracom.dts --> [from pi setup docs](https://github.com/newracom/nrc7292_sw_pkg/blob/master/dts/newracom_for_5.16_or_later.dts)

 - newracom-blacklist.conf --> [from pi setup docs](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-018-Raspberry_Pi_setup.pdf)

### System setup guide step-by-step (from setup_system.sh)
Unless otherwise noted, all steps are from newracom documentation linked elsewhere here.
1. Enables serial hardware for connection to the HAT, but turns off showing the TTY over the serial as we do not want a terminal running over the HAT
2. Turns on SPI, so we can connect to the HAT over SPI
3. Install and stop necessary packages
    - Installs packages necessary:
        - `raspberrypi-bootloader raspberrypi-kernel raspberrypi-kernel-headers`: For exposing otherwise inaccessible files to the nrc.ko kernel driver
        - `hostapd iptables`: (AP) For controlling DNS loaning and STA management.  Not technically needed for STA usecase
        - `git`: A sanity check for those who `scp`ed the repo over
        - `dhcpcd5 dnsmasq`: For controlling the management and loaning of IPs and DNS servers
        - `wpasupplicant`: For managing the system recpetion of the wifi and recognition that nrc.ko provides a wifi driver.  Incompatible with NetworkManager!  
    - (b) (not newracom documented) Mask NetworkManager to prevent it from also trying to start network interfaces, we have wpa_supplicant for that
4. Build and install the /sources/newracom.dts. This file blocks the loading of userspace spidev, which allows for the kernel level SPI control.  This file was changed in kernel 5.16.
5. Install /sources/newracom-blacklist.conf. This file blacklists the modules that allow the onboard pi broadcom wifi to work, as the userspace can often conflcit with two wifi drivers. (teledatics has found a way around this, not highlighted here.)
6. Backup the default wpa_supplicant.conf in case the user wants it, as `start.py` overwrites it with the `sta_halow_open.conf` we edited above. (Unecessary for clean install).
7. Enable i2c, mac80211 modules for linux as nrc.ko depends on them.  TODO: Does nrc actually use i2c??
8. Install /sources/newracom-blacklist.conf to blacklist brcmfmac and brcmutil (the onboard broadcom wifi), as these modules can in some cases conflict with the userspace utilities that configure halow.  However, at the driver level no reason exists for them to necessitate removal, so technically both WiFi networks *could* run at once.
    

### System bootup order of events
1. nrc-autostart runs nrc-wizard.sh stop
3. nrc-autostart begins running nrc-wizard.sh start-systemd
4. start.py completes insmod and awaits IP address or connects to AP
5. nrc-wizard.sh signals that startup is complete via reading output of start.py
6. nrc-led.service triggers, running nrc-led.sh, which begins setting LEDs

Possible routes:
start.py fails before step 7 --> service exits with failure
start.py fails after step 7 --> service enters run
start.py completes normally --> service enters run
nrc-led.service fails to start --> nrc-autostart.service ignores failure
nrc-autostart.service fails to start --> nrc.led never called
nrc-autostart nrc-wizard.sh (main) process exits --> nrc-autostart.service fails

### GUI luanchers

The gui launchers (mainly changing GPIO) were adapted from ALFA's 1.3.4 nrc_pkg .deb file, found [here](https://downloads.alfa.com.tw/raspbian/pool/contrib/n/nrc7292-sw-pkg/nrc7292-nrc-pkg_1.3.4-64-20220525_all.deb).  The gpio is changed in accordance with the [tech docs](https://docs.alfa.com.tw/Product/AHPI7292S/30_Technical_Details/), such that gpio pin 13 (hw 33) allows for a temporary change in mode.  The binaries are suffixed .exe however they are cross platform java applications with no depencies not provided by `default-jre`.

#### Updating to new newracom release (untested)
[See above for caveat](#board-data-file)

Re-run `install-nrc.sh` which runs:

`/home/pi/nrc7292_sw_pkg/package/evk/sw_pkg/update.sh` (updates the nrc_pkg, not recommended ATM)

This should simply pull new git sources and rebuild all necessary modules.





