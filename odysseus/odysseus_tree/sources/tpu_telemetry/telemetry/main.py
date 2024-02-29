import asyncio
import signal
from telemetry import server_data_pb2
from poll_data import example, can, on_board, halow
#from gen_data import server_data_pb2
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
    
def ask_exit(*args):
    STOP.set()

def publish_data(topic, message_data):
    # send the data
    client.publish(topic, message_data)

async def run(host):
    await client.connect(host, 1883)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect

    while True:
        items = can.fetch_data() + halow.fetch_data() + on_board.fetch_data()

        for file_data in items:
            print(file_data)
            topic = file_data[0]

            data = server_data_pb2.ServerData()

            data.unit = file_data[2]

            values = file_data[1]
            for val in values:
                data.value.append(val)
            
            message_data = data.SerializeToString()
            
            publish_data(topic, message_data)
            
        if STOP.is_set():
            await client.disconnect()
            return

        await asyncio.sleep(1)

    await STOP.wait()


if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    
    host = '127.0.0.1'

    loop.add_signal_handler(signal.SIGINT, ask_exit)
    loop.add_signal_handler(signal.SIGTERM, ask_exit)

    loop.run_until_complete(run(host))

def ask_exit(*args):
    STOP.set()
