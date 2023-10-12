This is the complete process to get Halow wifi working.

#### Made for newracom version 1.4.1


Setup assumes:

- Developer computer is linux (any version)
- SBC is Pi 4
- Halow hat is ALFA AHPI7292S in HOST mode
- An ethernet connection from computer to pi is available

# Setup Pi

### Image

1. Download, install, and open: [Rpi Imager](https://www.raspberrypi.com/software/)
2. Choose OS: Pi OS other > Raspberry OS lite (64-bit) Debian Bullseye (note once bookworm is released you may need to get the .img file via the internet and flahs via general disk image)
3. Choose Storage: micro-sdcard (note on Linux motherboard connected sd card readers might not show up)
4. Settings: Enable SSH, set username "pi" and password "Racecar202". Dont configure wifi or change username
5. Write

### Connect
Boot up the pi, and connect ethernet between pi and linux computer.

On computer's NetworkManager GUI:
Delete wired connection and create a wired connect (shared), then press connect.  Wait like 30 seconds.

On CLI: (TODO)

Use `arp -a` to get the pi ip (it is a number higher than the gateway but on the same subnet).  Ssh into rpi with above ip and correct username/password (`ssh pi@<IP>`).  If it fails try a different IP or wait until `arp -a` shows the MAC address for that IP and not `<incomplete>`.

### Download scripts
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

- uncomment and change ssid= to the SilexAH ssid
- `scan_ssid=1` (TODO not needed?)
- `scan_freq= <channel>`
- `freq_list= <channel>`

See channels [here](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-003-S1G_Channel.pdf), use the 2.4/5 ghz codes as linux doesn't understand sub-ghz.  Can use multiple channels by space-seperating the channel numbers.  **Ensure the AP is set to the correct channel!**  Optionally do not set this, and it will scan all channels to find the AP at ssid.

## Setup shortcuts and autostart
`cd ~/halow_setup`  
`sudo ./install_startup_script.sh`  

If you would like to autostart the script:  
`sudo systemctl enable nrc-autostart.service`  
When using the systemd service, use the shortcut `nrc-wizard startup-logs` to get the most recent invocation of nrc-autostart and what it prints out.  Note: any parameters past startup-logs will get piped into journalctl (one useful one is `-f` to live-reload the log).

Upon using the systemd unit, `nrc-led.service` is also run to allow for LED behaviors.  Manual `nrc-led` usage is not recommended as it is not aware of nrc status and can just write a bunch of errors to gpio.  
Current LED behavior:  
Red light --> blinking: on no IP; solid: on IP recieved  
Yellow light --> solid: pinged 8.8.8.8 successfully  

See [below](#change-configuration-and-other-fs-locations) for how to change such behavior.

# Use NRC manually
Start manually:  
`nrc-wizard start`

Stop manually (recommended be run on every shutdown or after Ctrl^C of start, no matter what!):  
`nrc-wizard stop`

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

`nrc-firmware-flash` --> Flashes firmware in DOWNLOAD mode, probably never needed for HOST mode  
`nrc-at-cmd-test` -->  ?  TODO: figure out what that does


# Sources and more info
Important: all scripts not home relative at the moment, **so user must be pi**


### Change configuration and other FS locations
There are many sources of configuration change, some not outlined above.  **All files meant to be edited to change configurations are in bold**

 - /home/pi/nrc_pkg/script/ -->
     - **start.py** (sets up all driver + networking, used by nrc-wizard script), [see the google doc with info regarding module settings of interest to edit](https://docs.google.com/document/d/1o79gr1qESW38YnxxlvXTVY8_S3Yupzfv_w48i5PA4q4/edit?usp=sharing)
     - stop.py (stops driver and associated process, used by nrc-wizard script)
     - cli_app (communicates with driver to show, configure, and debug various aspects of halow) [see below for usage](#documentation-of-setup)
     - **conf/US/sta_halow_open.conf** (a wpa_supplicant.conf file loaded when STA mode without security is run in US country (0 0 US)), see [here](http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf) for all possible parameters.  Parameters of note are outlined [above](#configure-connection)
 - /usr/local/sbin (in $PATH) -->
     - **nrc-wizard** (runs start and stop on systemd), edit START_PARAMETERS at the top of the file in order to change the configuration passed into start.py, including STA/AP, security, and country.  Default is `0 0 US`
     - nrc-firmware-flash (download mode GUI firmware flash tool)
     - nrc-at-cmd-test (GUI scan networks, etc.)
     - **nrc-led** (runs LED driver *only works automatically via systemd*), edit the paramters at the top of the file to change LED behavior

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
     

### Board data file

nrc7292_bd.dat --> [newracom made this for ALFA](https://github.com/newracom/nrc7292_sw_pkg/issues/60)

The actual process by which this file was made is not definite, all documentation [here](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-015-Transmit_Power_Control.pdf).  A GUI tool to make board data files was moved in 1.3.4, changelogs do not allude to why. **A newracom update could break ALFA compatability**, and ALFA has not updated their file since 1.3.4 rev2, and it does not work in 1.4.1 due to newracom breaking changes.  TODO: come up with a way to compile the above file and/or find the BoardDataEditor.exe.

### More sources
newracom.dts --> [for disabling userspace spidev](https://github.com/newracom/nrc7292_sw_pkg/blob/master/dts/newracom_for_5.16_or_later.dts)

newracom-blacklist.conf --> [from pi setup docs](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-018-Raspberry_Pi_setup.pdf)

### System bootup order of events (TODO: make less convoluted)
1. nrc-autostart runs nrc-wizard stop
3. nrc-autostart begins running nrc-wizard start-systemd
4. start.py completes insmod and awaits IP address or connects to AP
5. nrc-wizard signals that startup is complete via reading output of start.py
6. nrc-led.service triggers, running nrc-led, which begins setting LEDs

Possible routes:
start.py fails before step 7 --> service exits with failure
start.py fails after step 7 --> service enters run
start.py completes normally --> service enters run
nrc-led.service fails to start --> nrc-autostart.service ignores failure
nrc-autostart.service fails to start --> nrc.led never called
nrc-autostart nrc-wizard (main) process exits --> nrc-autostart.service fails

### Alfa sources

The gui launchers (mainly changing GPIO) were adapted from ALFA's 1.3.4 nrc_pkg .deb file, found [here](https://downloads.alfa.com.tw/raspbian/pool/contrib/n/nrc7292-sw-pkg/nrc7292-nrc-pkg_1.3.4-64-20220525_all.deb).

#### Updating to new newracom release (untested)
[See above for caveat](#board-data-file)

Re-run `install-nrc.sh` which runs:

`/home/pi/nrc7292_sw_pkg/package/evk/sw_pkg/update.sh` (updates the nrc_pkg, not recommended ATM)

This should simply pull new git sources and rebuild all necessary modules.






