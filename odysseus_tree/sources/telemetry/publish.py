import asyncio
import signal
import time


from . import MTCommand, MeasureTask, server_data_pb2
from gmqtt import Client as MQTTClient


# initialize connection
client = MQTTClient("base-station-publisher")
STOP = asyncio.Event()


def on_connect(client, flags, rc, properties):
    print("Connected")


def on_disconnect(client, packet, exc=None):
    print("Disconnected")


def ask_exit(*args, tasks: list):
    for task in tasks:
        if isinstance(task, MTCommand):
            task.__deinit__()
    STOP.set()


def publish_data(topic, message_data):
    # send the data
    client.publish(topic, message_data)


async def interval(task: MeasureTask):
    async for result in task.set_interval(STOP):
        time_us = time.time() * 1000000
        # process each tuple
        for packet in result:
            data = server_data_pb2.ServerData()
            topic, values, data.unit = packet
            data.time_us = int(time_us)
            # process the data values
            for val in values:
                data.values.append(val)
            else:
                message_data = data.SerializeToString()
                publish_data(topic, message_data)


async def run(host, tasks: list):
    await client.connect(host, 1883)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect

    stagger = 1 / len(tasks)
    for task in tasks:

        # if task is of type BufferedCommand, register its thread
        if isinstance(task, MTCommand):
            task.get_thread().start()

        # should not be awaited, this just gets run parallely along with other intervals.
        asyncio.create_task(interval(task))
        await asyncio.sleep(stagger)

    await STOP.wait()


def start_task(tasks: list):
    loop = asyncio.new_event_loop()

    host = "localhost"

    loop.add_signal_handler(signal.SIGINT, lambda *args: ask_exit(args, tasks))
    loop.add_signal_handler(signal.SIGTERM, lambda *args: ask_exit(args, tasks))

    loop.run_until_complete(run(host, tasks))
