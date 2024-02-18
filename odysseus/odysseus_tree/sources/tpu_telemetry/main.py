import asyncio
import signal
import server_data_pb2
from poll_data import example
import time

# data = server_data_pb2.ServerData()
# data.value = "50"
# data.unit = "C"

# initialize connection

STOP = asyncio.Event()

def ask_exit(*args):
    STOP.set()


async def run():
    client = await initialize()

    while True:
        items = example.fetch_data()
        print("hehe")
        for item in items:
            file_data = item
            data = server_data_pb2.ServerData()

            data.unit = file_data[2]

            values = file_data[1]
            for val in values:
                data.value.append(val)
            
            data.SerializeToString()
            print("hehe")
            publish_data(client, item[0], data)

        time.sleep(0.1)


import asyncio
from gmqtt import Client as MQTTClient

STOP = asyncio.Event()

def on_connect(client, flags, rc, properties):
    print('Connected')

def on_disconnect(client, packet, exc=None):
    print('Disconnected')

def publish_data(client, topic, message):
    print(client, topic, message)
    # Send the data of test
    client.publish(topic, message)

async def initialize():

    host = 'broker.emqx.io'

    client = MQTTClient("tpu-publisher")

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect # do we need this

    # Connecting the MQTT broker
    await client.connect(host, 1883)


if __name__ == '__main__':
    loop = asyncio.new_event_loop()

 #   loop.add_signal_handler(signal.SIGINT, ask_exit)
  #  loop.add_signal_handler(signal.SIGTERM, ask_exit)

    loop.run_until_complete(run())