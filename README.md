# [Odysseus 22A](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/107184222/Odysseus)
Our custom buildroot-based OS.  It enables the collection, translation, and transportation of data from the car to a base station which hosts data visualization and analytics systems as part of the [Odyssey 22A project](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/105283597/Wireless+22A+Software+Design).  Within the OS is the enablement configuration and code for the Wireless 22A and Siren 22A projects, both on the car and base station.  Enter the `odysseus` folder to read more.

## [Wireless 22A](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/71631135/Wireless+22A)
Our HaLow Wifi implementation and usage for low throughput high range TCP/IP data transmission.  HaLow (802.11ah) is a new 900 mhz unlicensed band wifi protocol which boasts an ultra-long range and low power usage.  This repository contains the buildroot enablement for the protocol with Newracom chips.

## [Siren 22A](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/107151426/Siren)
Siren is our [pub/sub](https://www.stackpath.com/edge-academy/what-is-pub-sub-messaging/) server that uses a MQTT server to send telemetry data from the car. Siren is a custom [Mosquitto](https://mosquitto.org) server.  Configuration code for mosquitto on the car lives in the rootfs overlays of buildroot, and for the base station it lies in the `extra` folder.

### About MQTT
For information about MQTT, check out [this confluence page](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/173113345/Delving+into+MQTT).

### Running with Docker
Custom image coming soon. For now, you can run with the instructions in the `extra/mosquitto_base` folder, and to achieve in-car configuration use the image but substitute the configurations with those found in the buildroot rootfs overlay for the TPU.

### Local Setup
Docker is easiest, commands are in `extra/mosquitto_base`.  If you would like to install locally, visit the mosquitto website to learn more.

### Testing Siren
To test that Siren is working properly, run the `subscriber.py` and `publisher.py` scripts in the `extra/siren_example` folder in the same environment that Siren is hosted in. After a few seconds, the terminal running the `subscriber.py` script should begin receiving messages, which means that Siren is working properly.
