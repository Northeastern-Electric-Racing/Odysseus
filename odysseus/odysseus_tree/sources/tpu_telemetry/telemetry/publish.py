import asyncio
import signal
from . import (
    server_data_pb2,
    routines,
    set_interval,
    poll_data as _,  # your editor lies, this is an important import.
)
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


async def interval(fn, freq):
    async for result in set_interval(fn, freq, STOP):
        for packet in result:
            print(packet)

            data = server_data_pb2.ServerData()
            topic, values, data.unit = packet

            for val in values:
                data.value.append(val)

            message_data = data.SerializeToString()
            publish_data(topic, message_data)


async def run(host):
    await client.connect(host, 1883)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect

    stagger = 1 / len(routines)

    for fn in routines:
        freq = routines[fn]

        # should not be awaited, this just gets run parallely along with other intervals.
        asyncio.create_task(interval(fn, freq))
        await asyncio.sleep(stagger)

    await STOP.wait()


def main():
    loop = asyncio.new_event_loop()

    host = "localhost"

    loop.add_signal_handler(signal.SIGINT, ask_exit)
    loop.add_signal_handler(signal.SIGTERM, ask_exit)

    loop.run_until_complete(run(host))


if __name__ == "__main__":
    main()
