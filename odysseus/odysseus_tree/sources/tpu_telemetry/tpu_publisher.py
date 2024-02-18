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

    await STOP.wait()
    await client.disconnect()