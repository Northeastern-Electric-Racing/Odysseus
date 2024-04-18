import asyncio
import signal

from telemetry.poll_data import environment, halow, on_board
import telemetry.poll_data.can as can;
import telemetry.poll_data.example as example;
from . import (
    BufferedCommand,
    MeasureTask,
    server_data_pb2
)
from gmqtt import Client as MQTTClient

TASKS = []

# initialize connection
client = MQTTClient("tpu-publisher")
STOP = asyncio.Event()


def on_connect(client, flags, rc, properties):
    print("Connected")


def on_disconnect(client, packet, exc=None):
    print("Disconnected")


def ask_exit(*args):
    STOP.set()
    for task in TASKS:
        if task.deinit != None:
            task.deinit()


def publish_data(topic, message_data):
    # send the data
    client.publish(topic, message_data)


async def interval(task: MeasureTask):
    async for result in task.set_interval(STOP):
        for packet in result:
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


    TASKS = [ example.ExampleMT(), # uncomment so example data is sent
             can.CanMT(),
             # environment.EnvironmentMT() # commented out bc sensor is currently broken
             halow.HalowThroughputMT(),
             halow.HalowMCSMT(),
             halow.HalowRSSIMT(),
             on_board.CpuTempMT(),
             on_board.CpuUsageMT(),
             on_board.BrokerCpuUsageMT(),
             on_board.MemAvailMT()
             ]

    stagger = 1 / len(TASKS)
    for task in TASKS:

        # if task is of type BufferedCommand, register it
        if isinstance(task, BufferedCommand):
            task.get_thread().start()

        # should not be awaited, this just gets run parallely along with other intervals.
        asyncio.create_task(interval(task))
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
