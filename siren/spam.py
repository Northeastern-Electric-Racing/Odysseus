import asyncio
import signal
import json
from gmqtt import Client as MQTTClient
from multiprocessing import Pool
from functools import partial
import paho.mqtt.client as mqtt
import time as time

def thread(list):
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect("192.168.100.12", 1883, 60)

    client.loop_start()
    json_msg = json.loads('{"data": 4, "units": "klubecks"}')

    while(True):
        message_info = client.publish("/mpu", "Hello from the publisher!")
        message_info.wait_for_publish()
        print(message_info.rc)

    client.loop_stop() 
    


# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+ msg.payload.decode("utf-8"))
    
if __name__ == '__main__':
    with Pool(processes=8) as p:
        p.map(thread, {1,2, 3, 4, 5, 6, 7, 8, 9})