This is the complete process to get the NEO-M8Q-0 working with PPS over GPIO for second start and NMEA sentences over UART for time and date.

Required equipment:
- Developer computer is **linux** (Ubuntu works fine) with...
    - SSH insalled: on Ubuntu its package `openssh-client` (so `apt install openssh-client`), so you can SSH into the pi
    - An internet connection: so the pi can recieve that connection, as the pi cannot network after step 1 of this guide!
    - A way to ethernet connect to the pi (adapters work)
    - A way to write to a microSD card
- A bookworm compatible pi
- A minimun 16 gb microSD card
- NEO-M8* series GPS module, with wired connections for **UART** and **timepulse** (to GPIO pin).

# Setup Pi
See the ../halow_setup/README.md file under "Setup Pi", change out `mv ~/Siren/odysseus/halow_setup ~/` to `mv ~/Siren/odysseus/gnss_setup ~/`  
If the use of GPS is not for the TPU, wireless can be enabled and used to connect to the Pi, ethernet is only required to allow for compatability with Halow configuration of the TPU.

# Install and configure PPS and GPSD
**IMPORTANT:** Before running `configure.sh` set the Pi GPIO pin connected to the `timepulse` pin of the NEO module using the parameter at the top of the file.  Additionaly, depending on your exact UART connection, the device name may need to be changed.
```
cd ~/gnss_setup
sudo ./install.sh
sudo ./configure.sh
sudo reboot now
```

### Configure hardware
Edit /etc/chrony/chrony.conf 
- Comment out any other ntp servers
- Add (be sure to put your device name in (no slashes, without dev.  Like /dev/ttyS0 becomes ttyS0)):
```
refclock SOCK /run/chrony.<device name here>.sock refid GPS precision 1e-1 offset 0.9999
refclock SOCK /run/chrony.pps0.sock refid PPS precision 1e-7
```

Run:
```
sudo systemctl enable gpsd
sudo systemctl enable chrony

sudo reboot now
```

### Tests/ensure working:
- `sudo ppstest /dev/pps0` --> ensure pps is working  
- `sudo ppscheck /dev/pps0` --> ensure gpsd can read PPS  
- `gpsmon` --> ensure GPS has lock  
- `cgps` --> See gps locks  (may not be compiled?)  
- `chronyc sources` --> see what time source chrony is using, and its accuracy  
- `chronyc sourcestats` --> ""
- `chronyc tracking` --> more accuracy info  

Not supported: `xgps` --> visually ensure GPS lock (requres special build)  

### Read GPS data
See the library [here](https://gpsd.io/libgps.html) to read data through libgps, bypassing GPSD isn't smart as it is running already for time data.  All NMEA and other configurations should be made through ubxtool with the GPSD daemon running.

# Sources and More Info

#### Background
The NEO-M8 series provides highly accurate timestamping down to the single digit milisecond range.  It uses the internal timebase and satellite frequency calculations generate a 1 Pulse-per-second signal.  The rising edge of that signal indicates the start of a new second.  In conjunction with an NMEA sentence which reads the second, time, date, and other info down to around 200ms, the system observing both outputs can calculate a very accurate (well below 15ms, claimed 50ns) time.

#### Configuration protocol for the GNSS Module
This setup uses two daemons and other hardware interfacing libraries.  Ublox releases proprietary and Windows only [U-center GUI](https://www.u-blox.com/en/product/u-center) to configure their GNSS modules, and leaves a binary protocol specification for those who want to use the industry standard OS widely known for hardware-interfacing systems (hint, it is what this project uses).  Thankfully though, GPSD built [ubxtool](https://gpsd.gitlab.io/gpsd/ubxtool.html) which allows us to pass in our own hex data without the required headers, timestamp, checksum, etc.  Some common universal changes are even built in flags! Note: NEO 9 series (protocol 27+ allows for key,value usage without hexadecimal).  Additionally, [PyGPSClient](https://github.com/semuconsulting/PyGPSClient#cli) attempts to be a linux U-Center, however it really shouldnt be needed for this project.

#### Actually recieving NMEA data and more
This task falls under GPSD, the linux standard for GPS data.  It runs as a server, collecting NMEA and other data at a source and publishing it in a standardized format.  What the `configure.sh` does is add the path to the UART (`/dev/ttyACM0`) and PPS (`/dev/pps0`) so GPSD knows where to read the GPS data.

#### Recieving pps data
This is more simple, as linux has a PPS kernel driver just waiting to be enabled. `configure.sh` just adds the necessary line to the boot configuration enabling pps on gpio at the pin specified.

#### Bringing it all together with chrony!
Chrony is a replacement for the traditonal NTPsec server, which provides much better support for single time sources and hardware sources.  It was designed to work well with GPSD, as they share some maintainers.  Adding the above chrony.conf lines ([source](https://chrony-project.org/faq.html#_how_should_chronyd_be_configured_with_gpsd)) tells chrony what clock source to use, including both PPS and NMEA.

Note: GPSD provides a socket to combine PPS and NMEA and make more accurate this connection.  This is in version 3.25+, and one of the reasons this script compiles gpsd.  Another is sporadic reports of never recieving a second NMEA sentence on NEO-M8 post bootup unless ubxtool unsets some changes.


## Problems:
Never recieving a GPS signal will result in wildly inaccurate time, probably right where last boot left off. However, the RTC on the NEO should provide PPS signal according to the time kept since last lock.  NMEA though won't provide anything without a lock, so that should be investigated.

Extra:

Chronyc config for bookworm installed GPSD (v3.22)
```
refclock PPS /dev/pps0 lock NMEA refid GPS
refclock SHM 0 offset 0.5 delay 0.1 refid GPS
```

