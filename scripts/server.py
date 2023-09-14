import asyncio
import websockets
from websockets.exceptions import ConnectionClosed
from websockets.server import WebSocketServerProtocol
from threading import Lock
from typing import List


SERVER_IP = "192.168.0.147"
SERVER_PORT = 8765


class TestMessage():
    """
    Test message format used for testing the websocket connections with data similar to what is
    coming from the car.
    """
    START_TIME = 1654705626000

    def __init__(self):
        self.time = TestMessage.START_TIME
        self.id = 514
        self.len = 8
        self.data = [0, 0, 24, 0, 0, 0, 0, 0]
        self.data_count = 1
        self.time_count = 1
    
    def update_message(self):
        self.time += self.time_count
        self.data[0] = self.data_count % 255
        self.time_count += 1
        self.data_count += 1

    def get_string(self):
        return f"T{self.time}{self.id:03x}{self.len}{self.get_data_string()}\r"

    def get_data_string(self):
        out = ""
        for d in self.data:
            out += f"{d:02x}"
        return out


class Socket():
    """
    Represents an individual socket connection.
    """
    def __init__(self, socket: WebSocketServerProtocol):
        self.socket = socket
        self.started = False # Whether data is being sent to this socket
        self.callbacks = {
            'start': self.start_data,
            'stop': self.stop_data
        }

    async def run(self):
        async for message in self.socket:
            if message in self.callbacks:
                self.callbacks.get(message)() # call the function
    
    async def send(self, message):
        try:
            await self.socket.send(message)
        except ConnectionClosed as cc:
            pass

    def start_data(self):
        self.started = True
    
    def stop_data(self):
        self.started = False


connections: List[Socket] = []
connection_lock = Lock() # to prevent concurrency issues between tasks
m = TestMessage()


async def sender():
    """
    Asynchronous task to send data to connected clients every second.
    """
    while True:
        message = m.get_string()
        with connection_lock:
            for connection in connections:
                if connection.started:
                    await connection.send(message)
        m.update_message()
        await asyncio.sleep(1)


async def monitor():
    """
    Asynchronous task to monitor the connections. Filters out closed connections every
    few seconds, and prints status information.
    """
    while True:
        with connection_lock:
            closed = filter(lambda con: con.socket.closed, connections)
            for c in closed:
                connections.remove(c)
            print(f"Connections: {len(connections)}")
            for connection in connections:
                print(f"  {connection.socket.remote_address} - started: {connection.started}")
        await asyncio.sleep(2)


async def handle(websocket: WebSocketServerProtocol):
    """
    Handles incoming connections by adding them to the connection list
    """
    socket = Socket(websocket)
    with connection_lock:
        connections.append(socket)
    await socket.run()


async def main():
    async with websockets.serve(handle, SERVER_IP, SERVER_PORT):
        asyncio.create_task(sender())
        asyncio.create_task(monitor())
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())