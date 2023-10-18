import paho.mqtt.client as mqtt
import time as time

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+ msg.payload.decode("utf-8"))

def publish(client):
    while(True):
        message_info = client.publish("/mpu", "Hello from the publisher!")
        message_info.wait_for_publish()
        print(message_info.rc)
        time.sleep(3)

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("127.0.0.1", 1883, 60)

client.loop_start()
publish(client)
client.loop_stop()