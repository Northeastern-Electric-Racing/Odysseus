# Wireless22A
Code for Wireless22A project.

## Siren
Siren is our [pub/sub](https://www.stackpath.com/edge-academy/what-is-pub-sub-messaging/) server that uses a MQTT server to send telemetry data from the car. Siren is a custom [Mosquitto](https://mosquitto.org) server.

### About MQTT
For information about MQTT, check out [this confluence page](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/173113345/Delving+into+MQTT).

### Running with Docker
Coming soon.

### Local Setup
To set up Siren locally on your machine, simply install using [these instructions](https://mosquitto.org/download/).


### Running Locally
To run Siren locally on your machine, simply use the `run` script from the `siren` directory.

- For Mac/Linux/WSL:
```console
$ ./run
```

- For Windows:

No script yet. Run the command:

```console
mosquitto -c mosquitto.conf
```

After that, Siren should start up and it is open to connections.

### Testing Siren
To test that Siren is working properly, run the `subscriber.py` and `publisher.py` scripts in the same environment that Siren is hosted in. After a few seconds, the terminal running the `subscriber.py` script should begin receiving messages, which means that Siren is working properly.
