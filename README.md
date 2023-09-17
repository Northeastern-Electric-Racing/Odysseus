# Wireless22A
Code for Wireless22A project.

## Siren
Siren is our [pub/sub](https://www.stackpath.com/edge-academy/what-is-pub-sub-messaging/) server that uses the WebSocket protocol to send telemetry data from the car. Siren is built off of the [Bun framework](https://bun.sh/), which is a JavaScript framework that has the capability to host extremely fast WebSocket servers using pub/sub messaging.

### About WebSockets
For information about WebSockets, check out [this confluence page](https://nerdocs.atlassian.net/wiki/spaces/NER/pages/161972226/WebSocket+Basics) about WebSocket basics.

### Running with Docker
Coming soon.

### Local Setup
To set up Siren locally on your machine, simply use the `install` script.

- For Mac/Linux/WSL:
```
$ ./install
```

- For Windows:
```
No script yet.
```
Native Windows support coming. See [issue #11](https://github.com/Northeastern-Electric-Racing/Odyssey/issues/11).


### Running Locally
To run Siren locally on your machine, simply use the `run` script.

- For Mac/Linux/WSL:
```
$ ./run
```

- For Windows:
```
No script yet.  See above.
```

After that, Siren should start up and it is open to connections.

### Testing Siren
To test that Siren is working properly, run the `subscriber.py` and `publisher.py` scripts in the same environment that Siren is hosted in. After a few seconds, the terminal running the `subscriber.py` script should begin receiving messages, which means that Siren is working properly.
