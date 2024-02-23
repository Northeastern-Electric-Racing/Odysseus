import asyncio
import signal
import server_data_pb2
from poll_data import example
import time
import asyncio
from gmqtt import Client as MQTTClient

# initialize connection

client = MQTTClient("tpu-publisher")

STOP = asyncio.Event()

def on_connect(client, flags, rc, properties):
    print('Connected')

def on_disconnect(client, packet, exc=None):
    print('Disconnected')

def publish_data(topic, message_data):
    print(client, topic, message_data)

    # Send the data of test
    client.publish(topic, message_data)

async def initialize():

    host = 'broker.emqx.io'

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect # do we need this

    # Connecting the MQTT broker
    await client.connect(host, 1883)

async def run():
    await initialize()

    while True:
        items = example.fetch_data()

        for item in items:
            file_data = item
            topic = file_data[0]

            data = server_data_pb2.ServerData()

            data.unit = file_data[2]

            values = file_data[1]
            for val in values:
                data.value.append(val)
            
            message_data = data.SerializeToString()

            publish_data(topic, message_data)

            await asyncio.sleep(1)


STOP = asyncio.Event()

if __name__ == '__main__':
    loop = asyncio.new_event_loop()

  #  loop.add_signal_handler(signal.SIGINT, ask_exit)
  #  loop.add_signal_handler(signal.SIGTERM, ask_exit)

    loop.run_until_complete(run())

def ask_exit(*args):
    STOP.set()