import asyncio
from websockets.sync.client import connect

def hello():
    with connect("ws://127.0.0.1:8080") as websocket:
        message = websocket.recv()
        print(f"Received: {message}")

hello()