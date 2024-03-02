import asyncio
import signal
from telemetry import routines, set_interval
from gmqtt import Client as MQTTClient

# initialize connection
client = MQTTClient("tpu-publisher")
STOP = asyncio.Event()


def on_connect(client, flags, rc, properties):
    print("Connected")


def on_disconnect(client, packet, exc=None):
    print("Disconnected")


def ask_exit(*args):
    STOP.set()


def publish_data(topic, message_data):
    # send the data
    client.publish(topic, message_data)


async def run(host):
    await client.connect(host, 1883)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect

    print(routines)

    stagger = 1 / len(routines)

    for fn in routines:
        freq = routines[fn]
        asyncio.threads.to_thread(lambda: set_interval(fn, freq))
        await asyncio.sleep(stagger)


def main():
    loop = asyncio.new_event_loop()

    host = "broker.emqx.io"

    loop.add_signal_handler(signal.SIGINT, ask_exit)
    loop.add_signal_handler(signal.SIGTERM, ask_exit)

    loop.run_until_complete(run(host))


if __name__ == "__main__":
    main()
